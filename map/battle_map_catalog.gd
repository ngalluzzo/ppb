class_name BattleMapCatalog
extends Resource

@export var display_name: String = ""
@export var map_scene: PackedScene
@export_file("*.png", "*.jpg", "*.webp") var thumbnail_path: String = ""
@export var thumbnail: Texture2D
