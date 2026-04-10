class_name WeatherWindRules
extends RefCounted

const MatchWeatherConfigScript = preload("res://battle/weather/resources/match_weather_config.gd")
const WeatherConfigResolverScript = preload("res://battle/weather/logic/weather_config_resolver.gd")

static func roll_wind_for_turn(config: MatchWeatherConfig, seed: int, turn_index: int) -> Vector2:
	if config == null:
		return Vector2.ZERO
	if WeatherConfigResolverScript.resolve_wind_variation_mode(config) == MatchWeatherConfigScript.WindVariationMode.STATIC_NEUTRAL:
		return Vector2.ZERO
	var min_strength: float = WeatherConfigResolverScript.resolve_wind_min_strength(config)
	var max_strength: float = WeatherConfigResolverScript.resolve_wind_max_strength(config)
	if max_strength <= 0.0:
		return Vector2.ZERO
	var rng := RandomNumberGenerator.new()
	rng.seed = int(hash("%s:wind:%s" % [seed, turn_index]))
	var strength: float = rng.randf_range(min_strength, maxf(min_strength, max_strength))
	var wind_sign: float = -1.0 if rng.randf() < 0.5 else 1.0
	return Vector2(strength * wind_sign, 0.0)
