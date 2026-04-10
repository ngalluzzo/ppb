class_name WeatherConfigResolver
extends RefCounted

static func resolve_forecast_pool(config: MatchWeatherConfig):
	if config == null:
		return null
	if config.allowed_forecast_pool_override != null:
		return config.allowed_forecast_pool_override
	if config.climate != null:
		return config.climate.allowed_forecast_pool
	return null

static func resolve_forecast_length(config: MatchWeatherConfig) -> int:
	if config == null:
		return 0
	if config.forecast_length > 0:
		return config.forecast_length
	if config.climate != null:
		return maxi(0, config.climate.default_forecast_length)
	return 0

static func resolve_event_interval(config: MatchWeatherConfig) -> int:
	if config == null:
		return 1
	if config.event_interval_turns > 0:
		return config.event_interval_turns
	if config.climate != null:
		return maxi(1, config.climate.default_event_interval_turns)
	return 1

static func resolve_wind_min_strength(config: MatchWeatherConfig) -> float:
	if config == null:
		return 0.0
	if config.wind_min_strength_override >= 0.0:
		return config.wind_min_strength_override
	if config.climate != null:
		return config.climate.wind_min_strength
	return 0.0

static func resolve_wind_max_strength(config: MatchWeatherConfig) -> float:
	if config == null:
		return 0.0
	if config.wind_max_strength_override >= 0.0:
		return config.wind_max_strength_override
	if config.climate != null:
		return config.climate.wind_max_strength
	return 0.0

static func resolve_wind_variation_mode(config: MatchWeatherConfig) -> MatchWeatherConfig.WindVariationMode:
	if config == null:
		return MatchWeatherConfig.WindVariationMode.RANDOM_EACH_TURN
	return config.wind_variation_mode
