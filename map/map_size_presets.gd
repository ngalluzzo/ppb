class_name MapSizePresets
extends RefCounted

const PRESETS := [
	{
		"label": "Duel (160x90 tiles)",
		"world_bounds": Rect2(-1280, -720, 2560, 1440),
		"camera_bounds": Rect2(-1280, -720, 2560, 1440),
		"spawn_left": Vector2(-640, -256),
		"spawn_right": Vector2(640, -256),
		"lane_width": 320.0,
		"sample_height": 192.0,
	},
	{
		"label": "Wide (192x96 tiles)",
		"world_bounds": Rect2(-1536, -768, 3072, 1536),
		"camera_bounds": Rect2(-1536, -768, 3072, 1536),
		"spawn_left": Vector2(-768, -288),
		"spawn_right": Vector2(768, -288),
		"lane_width": 352.0,
		"sample_height": 224.0,
	},
	{
		"label": "Epic (224x112 tiles)",
		"world_bounds": Rect2(-1792, -896, 3584, 1792),
		"camera_bounds": Rect2(-1792, -896, 3584, 1792),
		"spawn_left": Vector2(-960, -320),
		"spawn_right": Vector2(960, -320),
		"lane_width": 384.0,
		"sample_height": 256.0,
	},
]

static func get_labels() -> PackedStringArray:
	var labels := PackedStringArray()
	for preset in PRESETS:
		labels.append(preset["label"])
	return labels

static func get_preset(index: int) -> Dictionary:
	var clamped_index := clampi(index, 0, PRESETS.size() - 1)
	return PRESETS[clamped_index].duplicate(true)

static func get_world_bounds(index: int) -> Rect2:
	return get_preset(index)["world_bounds"]

static func get_camera_bounds(index: int) -> Rect2:
	return get_preset(index)["camera_bounds"]

static func get_spawn_positions(index: int) -> Array[Vector2]:
	var preset := get_preset(index)
	return [preset["spawn_left"], preset["spawn_right"]]

static func get_lane_width(index: int) -> float:
	return float(get_preset(index)["lane_width"])

static func get_sample_height(index: int) -> float:
	return float(get_preset(index)["sample_height"])
