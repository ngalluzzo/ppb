@tool
class_name ShotPreviewCapture
extends RefCounted

const COLOR_PALETTE := [
	Color(0.45, 0.88, 1.0, 0.95),
	Color(1.0, 0.61, 0.31, 0.95),
	Color(0.51, 0.94, 0.46, 0.95),
	Color(0.97, 0.57, 0.92, 0.95),
	Color(0.99, 0.88, 0.36, 0.95),
]

var _tracks: Dictionary = {}
var _had_projectiles: bool = false
var _max_airtime_seconds: float = 0.0

func reset() -> void:
	_tracks.clear()
	_had_projectiles = false
	_max_airtime_seconds = 0.0

func sample(world_root: Node, delta: float) -> void:
	if world_root == null:
		return
	var active_ids := {}
	for child in world_root.get_children():
		if child is Projectile:
			var projectile := child as Projectile
			var id := projectile.get_instance_id()
			active_ids[id] = true
			_track_projectile(projectile)
			_had_projectiles = true
			var track: Dictionary = _tracks[id]
			track["active"] = true
			track["airtime"] = float(track.get("airtime", 0.0)) + delta
			track["last_snapshot"] = projectile.get_debug_snapshot()
			var points: Array = track.get("points", [])
			points.append(projectile.global_position)
			track["points"] = points
			track["color"] = _get_track_color(int(track.get("projectile_index", 0)))
			_max_airtime_seconds = maxf(_max_airtime_seconds, float(track.get("airtime", 0.0)))
	for id in _tracks.keys():
		if active_ids.has(id):
			continue
		var track: Dictionary = _tracks[id]
		if bool(track.get("active", false)):
			track["active"] = false
			var points: Array = track.get("points", [])
			track["endpoint"] = points[-1] if not points.is_empty() else Vector2.ZERO

func get_snapshot() -> Dictionary:
	var trajectories: Array = []
	var endpoints: Array = []
	for id in _tracks.keys():
		var track: Dictionary = _tracks[id]
		var points: Array = track.get("points", [])
		var color: Color = track.get("color", Color.WHITE)
		trajectories.append({
			"projectile_index": int(track.get("projectile_index", 0)),
			"points": points.duplicate(),
			"color": color,
			"active": bool(track.get("active", false)),
		})
		if not points.is_empty():
			endpoints.append({
				"projectile_index": int(track.get("projectile_index", 0)),
				"position": track.get("endpoint", null) if track.get("endpoint", null) != null else points[-1],
				"color": color,
				"impact_label": str(track.get("impact_label", "")),
			})
	var spread_width := 0.0
	if endpoints.size() > 1:
		var first_position: Vector2 = endpoints[0].get("position", Vector2.ZERO)
		var min_x: float = first_position.x
		var max_x: float = first_position.x
		for endpoint in endpoints:
			var position: Vector2 = endpoint.get("position", Vector2.ZERO)
			min_x = minf(min_x, position.x)
			max_x = maxf(max_x, position.x)
		spread_width = max_x - min_x
	return {
		"had_projectiles": _had_projectiles,
		"trajectories": trajectories,
		"endpoints": endpoints,
		"projectile_count": _tracks.size(),
		"active_projectiles": _count_active_tracks(),
		"spread_width": spread_width,
		"max_airtime_seconds": _max_airtime_seconds,
	}

func _track_projectile(projectile: Projectile) -> void:
	var id := projectile.get_instance_id()
	if _tracks.has(id):
		return
	_tracks[id] = {
		"projectile_index": projectile.projectile_index,
		"points": [projectile.global_position],
		"endpoint": null,
		"impact_label": "",
		"active": true,
		"airtime": 0.0,
		"color": _get_track_color(projectile.projectile_index),
		"last_snapshot": projectile.get_debug_snapshot(),
	}
	if not projectile.impact_submitted.is_connected(_on_projectile_impact.bind(id)):
		projectile.impact_submitted.connect(_on_projectile_impact.bind(id))

func _on_projectile_impact(event: ImpactEvent, projectile_id: int) -> void:
	if not _tracks.has(projectile_id) or event == null:
		return
	var track = _tracks[projectile_id]
	track["endpoint"] = event.position
	track["impact_label"] = "mobile" if event.hit_mobile != null else "terrain"

func _count_active_tracks() -> int:
	var count := 0
	for track in _tracks.values():
		if bool(track.get("active", false)):
			count += 1
	return count

func _get_track_color(projectile_index: int) -> Color:
	return COLOR_PALETTE[projectile_index % COLOR_PALETTE.size()]
