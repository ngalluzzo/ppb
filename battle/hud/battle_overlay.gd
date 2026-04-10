class_name BattleOverlay
extends Control

const StatusBadgeViewModelScript = preload("res://ui/contracts/status_badge_view_model.gd")
const CombatantPanelViewScript = preload("res://ui/contracts/combatant_panel_view.gd")
const GameScreenShellScript = preload("res://ui/composed/shared/game_screen_shell.gd")
const TurnHeaderScript = preload("res://ui/composed/battle/turn_header.gd")
const FireControlClusterScript = preload("res://ui/composed/battle/fire_control_cluster.gd")
const CombatantStatusPanelScript = preload("res://ui/composed/battle/combatant_status_panel.gd")
const WindWeatherStripScript = preload("res://ui/composed/battle/wind_weather_strip.gd")
const BattleEventTickerScript = preload("res://ui/composed/battle/battle_event_ticker.gd")
const AppLabelScript = preload("res://ui/system/primitives/app_label.gd")
const AppUIScript = preload("res://ui/system/theme/app_ui.gd")
const DEBUG_TRAVERSAL := true

var _controller: MobileController
var _latest_weather_state

var _shell: GameScreenShell
var _turn_header: TurnHeader
var _fire_controls: FireControlCluster
var _combatant_panel: CombatantStatusPanel
var _weather_strip: WindWeatherStrip
var _event_ticker: BattleEventTicker
var _traversal_label: AppLabel

func _ready() -> void:
	_build_ui()

func on_turn_started(controller: MobileController) -> void:
	connect_to_controller(controller)

func on_turn_ended(_ended_controller: MobileController) -> void:
	_event_ticker.set_events(["Turn ended"])

func _process(_delta: float) -> void:
	if not DEBUG_TRAVERSAL or _traversal_label == null:
		return
	_refresh_traversal_debug()

func connect_to_controller(controller: MobileController) -> void:
	if controller == null:
		return
	if _controller != null and _controller.control_state_changed.is_connected(_on_control_state_changed):
		_controller.control_state_changed.disconnect(_on_control_state_changed)
	if _controller != null and _controller.status_view_states_changed.is_connected(_on_status_view_states_changed):
		_controller.status_view_states_changed.disconnect(_on_status_view_states_changed)
	_controller = controller
	_controller.control_state_changed.connect(_on_control_state_changed)
	_controller.status_view_states_changed.connect(_on_status_view_states_changed)
	_on_control_state_changed(controller.get_control_state())
	_refresh_status_panel()
	_refresh_traversal_debug()

func on_weather_state_changed(state) -> void:
	_latest_weather_state = state
	if state == null:
		_weather_strip.set_weather("wind: 0", "weather: clear", "forecast: clear")
		return
	var active_name := "clear"
	if state.active_event != null and state.active_event.definition != null:
		active_name = state.active_event.definition.display_name
	var entries: Array[String] = []
	for entry in state.forecast:
		if entry == null or entry.definition == null:
			continue
		entries.append(entry.definition.display_name)
		if entries.size() >= 4:
			break
	_weather_strip.set_weather(
		"wind: %.0f" % state.wind_vector.x,
		"weather: %s" % active_name,
		"forecast: %s" % (" -> ".join(entries) if not entries.is_empty() else "clear")
	)

func _on_status_view_states_changed(_view_states: Array) -> void:
	_refresh_status_panel()

func _on_control_state_changed(state: MobileControlState) -> void:
	_fire_controls.set_control_state(state)
	_turn_header.set_turn_info(
		state.combatant_id if state != null and state.combatant_id != "" else "Active Unit",
		"Aiming" if state != null and state.can_control else "Locked",
		"READY" if state != null and state.can_fire else "--"
	)
	_event_ticker.set_events([
		"shot: %s" % (str(state.selected_shot_slot) if state != null else "shot_1"),
		"control: %s" % ("live" if state != null and state.can_control else "idle"),
		"fire: %s" % ("armed" if state != null and state.can_fire else "waiting"),
	])
	_refresh_status_panel()
	_refresh_traversal_debug()

func _refresh_status_panel() -> void:
	var view := CombatantPanelViewScript.new()
	if _controller == null:
		view.display_name = "No Active Unit"
		view.angle_text = "-"
		view.power_text = "-"
		view.thrust_text = "-"
		view.shot_slot_text = "-"
		view.status_badges = []
		_combatant_panel.set_view(view)
		return
	var state := _controller.get_control_state()
	view.combatant_id = _controller.get_combatant_id()
	view.display_name = view.combatant_id if view.combatant_id != "" else "Active Unit"
	view.angle_text = "%d°" % int(round(state.current_angle))
	view.power_text = "%d / %d" % [int(round(state.current_power)), int(round(state.max_power))]
	view.thrust_text = "%d / %d" % [int(round(state.remaining_thrust)), int(round(state.max_thrust))]
	view.shot_slot_text = str(state.selected_shot_slot)
	view.can_control = state.can_control
	view.can_fire = state.can_fire
	view.status_badges = []
	for status_view in _controller.get_status_view_states():
		view.status_badges.append(StatusBadgeViewModelScript.from_status_view_state(status_view))
	_combatant_panel.set_view(view)

func _refresh_traversal_debug() -> void:
	if _traversal_label == null:
		return
	_traversal_label.visible = DEBUG_TRAVERSAL
	if not DEBUG_TRAVERSAL:
		return
	if _controller == null:
		_traversal_label.text = "traversal: no active unit"
		return
	_traversal_label.text = _controller.get_traversal_debug_text()

func _build_ui() -> void:
	for child in get_children():
		child.queue_free()
	AppUIScript.apply_theme(self, AppUIScript.Scope.RUNTIME)
	_shell = GameScreenShellScript.new()
	add_child(_shell)

	var header_box := HBoxContainer.new()
	header_box.size_flags_horizontal = SIZE_EXPAND_FILL
	_shell.get_header_root().add_child(header_box)

	_turn_header = TurnHeaderScript.new()
	_turn_header.size_flags_horizontal = SIZE_EXPAND_FILL
	header_box.add_child(_turn_header)

	_weather_strip = WindWeatherStripScript.new()
	_weather_strip.size_flags_horizontal = SIZE_EXPAND_FILL
	header_box.add_child(_weather_strip)
	on_weather_state_changed(null)

	var body_box := HBoxContainer.new()
	body_box.size_flags_horizontal = SIZE_EXPAND_FILL
	body_box.size_flags_vertical = SIZE_EXPAND_FILL
	_shell.get_body_root().add_child(body_box)

	_fire_controls = FireControlClusterScript.new()
	_fire_controls.size_flags_horizontal = SIZE_EXPAND_FILL
	body_box.add_child(_fire_controls)

	_combatant_panel = CombatantStatusPanelScript.new()
	_combatant_panel.size_flags_horizontal = SIZE_EXPAND_FILL
	body_box.add_child(_combatant_panel)

	_event_ticker = BattleEventTickerScript.new()
	_shell.get_footer_root().add_child(_event_ticker)

	_traversal_label = AppLabelScript.new()
	_traversal_label.scope = AppUIScript.Scope.RUNTIME
	_traversal_label.role = "caption"
	_traversal_label.text_role = "muted"
	_shell.get_footer_root().add_child(_traversal_label)

	_on_control_state_changed(null)
