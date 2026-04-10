extends SceneTree

const ImpactContextResolverScript = preload("res://battle/logic/impact/impact_context_resolver.gd")
const ImpactDamageRulesScript = preload("res://battle/logic/impact/impact_damage_rules.gd")
const ImpactStatusRulesScript = preload("res://battle/logic/impact/impact_status_rules.gd")
const ImpactTerrainRulesScript = preload("res://battle/logic/impact/impact_terrain_rules.gd")
const WeatherImpactContextScript = preload("res://battle/weather/weather_impact_context.gd")
const StatusApplicationScript = preload("res://mobile/status/status_application.gd")

class FakeMobile:
	extends Node2D
	var mobile_def
	var stat_container
	var status_controller

class DummyTileSet:
	var tile_size: Vector2i = Vector2i(16, 16)

class DummyTileDefinition:
	var projectile_resistance: float = 1.0

	func _init(p_projectile_resistance: float = 1.0) -> void:
		projectile_resistance = p_projectile_resistance

class DummyTerrain:
	extends RefCounted
	var tile_set = DummyTileSet.new()
	var degraded_tiles: Array[Vector2i] = []
	var tiles: Dictionary = {}

	func local_to_map(pos: Vector2) -> Vector2i:
		return Vector2i(int(floor(pos.x / float(tile_set.tile_size.x))), int(floor(pos.y / float(tile_set.tile_size.y))))

	func to_local(pos: Vector2) -> Vector2:
		return pos

	func get_tile_definition(tile_pos: Vector2i):
		return tiles.get(tile_pos, null)

	func degrade_tile(tile_pos: Vector2i, _impact_position: Vector2) -> void:
		degraded_tiles.append(tile_pos)

class ProbeStatContainer:
	extends StatContainer
	var recorded_damage: Array[float] = []

	func take_damage(amount: float) -> void:
		recorded_damage.append(amount)

class ProbeStatusController:
	extends StatusController
	var applications: Array = []

	func apply_status(application) -> void:
		applications.append(application)

class DummyBattleSystem:
	extends RefCounted
	var _units: Array = []

	func _init(p_units: Array) -> void:
		_units = p_units

	func get_units() -> Array:
		return _units

class DummyWeatherController:
	extends RefCounted
	var impact_context: WeatherImpactContext = WeatherImpactContextScript.new()
	var applications: Array = []

	func build_impact_context(_event: ImpactEvent) -> WeatherImpactContext:
		return impact_context

	func build_impact_status_applications(_event: ImpactEvent, _battle_system, _splash_radius: float = -1.0) -> Array:
		return applications

func _init() -> void:
	call_deferred("_run")

func _make_probe_mobile(position: Vector2 = Vector2.ZERO):
	var mobile := FakeMobile.new()
	mobile.global_position = position
	mobile.mobile_def = MobileDefinition.new()
	mobile.mobile_def.core_damage_multiplier = 1.5
	mobile.stat_container = ProbeStatContainer.new()
	mobile.status_controller = ProbeStatusController.new()
	return mobile

func _run() -> void:
	var impact_def := ImpactDefinition.new()
	impact_def.damage = 100.0
	impact_def.radius = 32.0
	impact_def.drill_power = 3.0

	var terrain := DummyTerrain.new()
	terrain.tiles[Vector2i(2, 2)] = DummyTileDefinition.new(1.0)
	terrain.tiles[Vector2i(3, 2)] = DummyTileDefinition.new(1.0)
	terrain.tiles[Vector2i(4, 2)] = DummyTileDefinition.new(4.0)

	var direct_mobile = _make_probe_mobile()
	var splash_mobile_a = _make_probe_mobile(Vector2(0.0, 0.0))
	var splash_mobile_b = _make_probe_mobile(Vector2(16.0, 0.0))
	var splash_mobile_c = _make_probe_mobile(Vector2(80.0, 0.0))

	var weather := DummyWeatherController.new()
	weather.impact_context = WeatherImpactContextScript.new(120.0, 40.0, 2.0)
	weather.applications = [
		StatusApplicationScript.new(
			load("res://roster/statuses/mired.tres"),
			&"weather",
			"probe",
			1,
			1,
			-1,
			"",
			splash_mobile_a
		)
	]

	var terrain_event := ImpactEvent.new(Vector2(32.0, 32.0), Vector2.UP, impact_def)
	var terrain_context = ImpactContextResolverScript.resolve(terrain_event, weather)
	ImpactTerrainRulesScript.apply_terrain_damage(terrain_event, terrain_context, terrain)

	var direct_event := ImpactEvent.new(
		Vector2.ZERO,
		Vector2.ZERO,
		impact_def,
		0,
		-1,
		"",
		-1,
		ImpactEvent.HitZone.CORE,
		direct_mobile
	)
	var direct_context = ImpactContextResolverScript.resolve(direct_event, weather)
	ImpactDamageRulesScript.apply_direct_damage(direct_event, direct_context)

	var splash_event := ImpactEvent.new(Vector2.ZERO, Vector2.ZERO, impact_def)
	var battle_system := DummyBattleSystem.new([splash_mobile_a, splash_mobile_b, splash_mobile_c])
	var splash_context = ImpactContextResolverScript.resolve(splash_event, weather)
	ImpactDamageRulesScript.apply_splash_damage(splash_event, splash_context, battle_system.get_units())
	ImpactStatusRulesScript.apply_impact_statuses(splash_event, splash_context, battle_system, weather)

	print("--- impact rules probe ---")
	print("terrain_damage tiles=%s drill=%s radius=%s" % [
		terrain.degraded_tiles,
		terrain_context.terrain_drill_power,
		terrain_context.radius
	])
	print("direct_damage core=%s" % direct_mobile.stat_container.recorded_damage)
	print("splash_damage a=%s b=%s c=%s statuses=%s" % [
		splash_mobile_a.stat_container.recorded_damage,
		splash_mobile_b.stat_container.recorded_damage,
		splash_mobile_c.stat_container.recorded_damage,
		splash_mobile_a.status_controller.applications.size()
	])
	direct_mobile.stat_container.free()
	splash_mobile_a.stat_container.free()
	splash_mobile_b.stat_container.free()
	splash_mobile_c.stat_container.free()
	weather.applications.clear()
	direct_mobile.free()
	splash_mobile_a.free()
	splash_mobile_b.free()
	splash_mobile_c.free()
	quit()
