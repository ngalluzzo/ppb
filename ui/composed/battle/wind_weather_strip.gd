@tool
class_name WindWeatherStrip
extends "res://ui/system/patterns/summary_strip.gd"

func set_weather(wind_text: String, weather_text: String, forecast_text: String) -> void:
	set_parts([wind_text, weather_text, forecast_text])

