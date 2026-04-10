@tool
class_name ShotPreviewOverrides
extends RefCounted

var shot_pattern: ShotPattern
var arc_config: ArcConfig
var projectile_definition: ProjectileDefinition
var impact_definition: ImpactDefinition
var phase_line: PhaseLine
var phase_entries: Array[PhaseEntry] = []
var angle: float = 45.0
var power: float = 50.0
var facing_direction: int = 1
var weather_config: MatchWeatherConfig
var preview_mobile_definition: MobileDefinition

static func from_bundle(bundle: ShotPreviewResourceBundle) -> ShotPreviewOverrides:
	var overrides := ShotPreviewOverrides.new()
	if bundle == null:
		return overrides
	overrides.shot_pattern = bundle.shot_pattern.duplicate(false) if bundle.shot_pattern != null else null
	overrides.arc_config = bundle.arc_config.duplicate(true) if bundle.arc_config != null else null
	overrides.projectile_definition = bundle.projectile_definition.duplicate(true) if bundle.projectile_definition != null else null
	overrides.impact_definition = bundle.impact_definition.duplicate(true) if bundle.impact_definition != null else null
	overrides.phase_line = bundle.phase_line.duplicate(false) if bundle.phase_line != null else null
	overrides.phase_entries = []
	for entry in bundle.phase_entries:
		overrides.phase_entries.append(entry.duplicate(true) if entry != null else null)
	if overrides.phase_line != null:
		overrides.phase_line.phases = overrides.phase_entries.duplicate()
	if overrides.projectile_definition != null:
		overrides.projectile_definition.impact_def = overrides.impact_definition
	if overrides.shot_pattern != null:
		overrides.shot_pattern.arc_config = overrides.arc_config
		overrides.shot_pattern.projectile_def = overrides.projectile_definition
		overrides.shot_pattern.phase_line = overrides.phase_line
	overrides.preview_mobile_definition = bundle.preview_mobile_definition
	var cannon_def := bundle.get_preview_cannon_definition()
	if cannon_def != null:
		overrides.angle = cannon_def.initial_angle
		overrides.power = (cannon_def.min_power + cannon_def.max_power) * 0.5
	overrides.facing_direction = 1
	return overrides
