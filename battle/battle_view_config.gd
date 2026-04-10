class_name BattleViewConfig
extends RefCounted

const VIEWPORT_SIZE := Vector2i(1280, 720)
const DEFAULT_ZOOM := Vector2(0.5, 0.5)

static func get_visible_world_size() -> Vector2:
	return Vector2(VIEWPORT_SIZE.x, VIEWPORT_SIZE.y) * DEFAULT_ZOOM
