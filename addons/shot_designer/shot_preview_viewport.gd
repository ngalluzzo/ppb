@tool
class_name ShotPreviewViewport
extends VBoxContainer

const BattleSystemScene = preload("res://battle/battle_system.tscn")
const AppUIScript = preload("res://ui/system/theme/app_ui.gd")
const StatusBannerScript = preload("res://ui/system/blocks/status_banner.gd")
const ShotExecutionServiceScript = preload("res://weapon/shot/shot_execution_service.gd")
const ShotPreviewBoundariesScript = preload("res://addons/shot_designer/shot_preview_boundaries.gd")
const ShotPreviewCaptureScript = preload("res://addons/shot_designer/shot_preview_capture.gd")
const ShotPreviewLauncherScript = preload("res://addons/shot_designer/shot_preview_launcher.gd")

class OverlayLayer:
	extends Control

	var capture_snapshot: Dictionary = {}

	func _draw() -> void:
		var trajectories: Array = capture_snapshot.get("trajectories", [])
		for track in trajectories:
			var points: Array = track.get("points", [])
			var color: Color = track.get("color", Color.WHITE)
			for index in range(1, points.size()):
				draw_line(points[index - 1], points[index], color, 2.0)
		var endpoints: Array = capture_snapshot.get("endpoints", [])
		for endpoint in endpoints:
			var position: Vector2 = endpoint.get("position", Vector2.ZERO)
			var color: Color = endpoint.get("color", Color.WHITE)
			draw_circle(position, 5.0, color)
			draw_arc(position, 10.0, 0.0, TAU, 24, color, 2.0)

	func set_capture_snapshot(snapshot: Dictionary) -> void:
		capture_snapshot = snapshot
		queue_redraw()

signal preview_updated(snapshot: Dictionary)

var _viewport_container: SubViewportContainer
var _viewport: SubViewport
var _overlay: OverlayLayer
var _summary_banner: Control
var _status_banner: Control
var _battle_system: BattleSystem
var _shot_execution_service: ShotExecutionService
var _boundaries: ShotPreviewBoundaries
var _capture: ShotPreviewCapture = ShotPreviewCaptureScript.new()
var _launcher: ShotPreviewLauncher = ShotPreviewLauncherScript.new()
var _session: ShotPreviewSession
var _pending_refresh_id: int = 0
var _actor_node: Node

func _ready() -> void:
	size_flags_vertical = SIZE_EXPAND_FILL
	size_flags_horizontal = SIZE_EXPAND_FILL
	AppUIScript.apply_theme(self, AppUIScript.Scope.EDITOR)
	_viewport_container = SubViewportContainer.new()
	_viewport_container.size_flags_vertical = SIZE_EXPAND_FILL
	_viewport_container.size_flags_horizontal = SIZE_EXPAND_FILL
	_viewport_container.stretch = false
	add_child(_viewport_container)

	_viewport = SubViewport.new()
	_viewport.disable_3d = true
	_viewport.handle_input_locally = false
	_viewport.transparent_bg = false
	_viewport_container.add_child(_viewport)

	_overlay = OverlayLayer.new()
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_viewport_container.add_child(_overlay)

	_summary_banner = StatusBannerScript.new()
	_summary_banner.scope = AppUIScript.Scope.EDITOR
	_summary_banner.tone = "muted"
	add_child(_summary_banner)

	_status_banner = StatusBannerScript.new()
	_status_banner.scope = AppUIScript.Scope.EDITOR
	_status_banner.tone = "info"
	add_child(_status_banner)

	_ensure_preview_runtime()

func _process(delta: float) -> void:
	if _battle_system == null or _capture == null:
		return
	_capture.sample(_battle_system.get_world_root(), delta)
	var snapshot := _capture.get_snapshot()
	_overlay.set_capture_snapshot(snapshot)
	_summary_banner.set_text_value(_format_summary(snapshot))
	preview_updated.emit(snapshot)

func set_session(session: ShotPreviewSession) -> void:
	_session = session
	request_refresh()

func request_refresh() -> void:
	_pending_refresh_id += 1
	call_deferred("_restart_preview", _pending_refresh_id)

func get_capture_snapshot() -> Dictionary:
	return _capture.get_snapshot() if _capture != null else {}

func _restart_preview(request_id: int) -> void:
	if request_id != _pending_refresh_id:
		return
	_ensure_preview_runtime()
	_clear_preview_actor()
	_capture.reset()
	_overlay.set_capture_snapshot({})
	_summary_banner.set_text_value("No preview.")
	if _session == null or not _session.is_ready():
		_status_banner.tone = "muted"
		_status_banner.set_text_value("Select a shot or mobile to start previewing.")
		return
	_status_banner.tone = "info"
	_status_banner.set_text_value("Restarting exact preview...")
	_battle_system.begin_editor_preview(_session.bundle.get_display_name(), _session.overrides.weather_config)
	_configure_preview_surface()
	await get_tree().process_frame
	if request_id != _pending_refresh_id:
		return

	var actor_info := _launcher.spawn_actor(_session, _battle_system)
	var actor_node := actor_info.get("node") as Node
	_actor_node = actor_node
	var cannon := actor_info.get("cannon") as Cannon
	if request_id != _pending_refresh_id:
		if actor_node != null and is_instance_valid(actor_node):
			actor_node.queue_free()
		if _actor_node == actor_node:
			_actor_node = null
		return
	if cannon == null:
		_status_banner.tone = "error"
		_status_banner.set_text_value("Could not create preview cannon.")
		return
	await get_tree().process_frame
	if request_id != _pending_refresh_id:
		if actor_node != null and is_instance_valid(actor_node):
			actor_node.queue_free()
		if _actor_node == actor_node:
			_actor_node = null
		return

	var event := _launcher.build_shot_event(_session, cannon, _battle_system.get_weather_controller())
	if event == null:
		_status_banner.tone = "error"
		_status_banner.set_text_value("Could not build preview shot event.")
		return
	_shot_execution_service.execute(event, _battle_system)
	_status_banner.tone = "success"
	_status_banner.set_text_value("Preview running.")

func _ensure_preview_runtime() -> void:
	if _battle_system == null:
		_battle_system = BattleSystemScene.instantiate() as BattleSystem
		_battle_system.editor_preview_enabled = false
		_viewport.add_child(_battle_system)
	if _shot_execution_service == null:
		_shot_execution_service = ShotExecutionServiceScript.new()
		add_child(_shot_execution_service)

func _configure_preview_surface() -> void:
	var bounds := _battle_system.editor_preview_bounds
	_viewport.size = Vector2i(int(bounds.size.x), int(bounds.size.y))
	_viewport_container.custom_minimum_size = bounds.size
	_overlay.custom_minimum_size = bounds.size
	_battle_system.position = -bounds.position
	if _boundaries == null or not is_instance_valid(_boundaries):
		_boundaries = ShotPreviewBoundariesScript.new()
		_battle_system.get_world_root().add_child(_boundaries)
	elif _boundaries.get_parent() != _battle_system.get_world_root():
		_boundaries.reparent(_battle_system.get_world_root(), false)
	_boundaries.configure(bounds, _battle_system.editor_preview_floor_y, _battle_system.editor_preview_wall_x)

func _clear_preview_actor() -> void:
	if _battle_system != null:
		_battle_system.end_editor_preview()
	if _actor_node != null and is_instance_valid(_actor_node):
		_actor_node.queue_free()
	_actor_node = null

func _format_summary(snapshot: Dictionary) -> String:
	if snapshot.is_empty():
		return "No preview capture."
	return "projectiles=%d active=%d airtime=%.2fs spread=%.1f" % [
		int(snapshot.get("projectile_count", 0)),
		int(snapshot.get("active_projectiles", 0)),
		float(snapshot.get("max_airtime_seconds", 0.0)),
		float(snapshot.get("spread_width", 0.0))
	]
