class_name MobileDefinition
extends Resource

@export var name: String = "unnamed"
@export var mobile_class: MobileClass.Type = MobileClass.Type.LIGHT
@export var cannon_def: CannonDefinition
@export var stat_def: StatDefinition
@export var shot_1: ShotPattern
@export var shot_2: ShotPattern
@export var shot_ss: ShotPattern

@export_group("Visuals")
## Path to folder containing sprite PNGs. Must end with /
@export var sprite_path: String = ""
## Optional sprite filename stem. When empty, falls back to `name.to_lower()`.
@export var sprite_stem: String = ""

@export_group("Hit Zones")
## Damage multiplier when hitting the core weak point
@export var core_damage_multiplier: float = 1.5
## Radius of the full body hit zone
@export var body_zone_radius: float = 24.0
## Radius of the core weak point zone
@export var core_zone_radius: float = 8.0
## Offset of the core zone from the mobile center
@export var core_zone_offset: Vector2 = Vector2.ZERO

@export_group("Physics")
## Size of the physics body for terrain collision
@export var body_size: Vector2 = Vector2(32.0, 32.0)
## Local mount point for the cannon relative to the mobile body origin.
@export var cannon_mount_offset: Vector2 = Vector2(0.0, -8.0)

@export_group("Movement")
## Maximum grounded walk speed in pixels per second.
@export var walk_speed: float = 140.0
## How quickly grounded movement accelerates toward target speed.
@export var ground_acceleration: float = 900.0
## How quickly grounded movement slows when no input is applied.
@export var ground_deceleration: float = 1200.0
## Maximum slope angle, in degrees, that counts as walkable ground.
@export_range(0.0, 89.0, 0.5, "radians_as_degrees") var max_walkable_slope_degrees: float = 40.0
## Maximum vertical ledge height that can be smoothed over while grounded.
@export var step_height: float = 6.0
## Forward probe distance used when evaluating a possible step-up.
@export var step_forward_probe: float = 6.0
## Gravity applied while airborne.
@export var gravity: float = 1600.0
## Maximum downward velocity while falling.
@export var max_fall_speed: float = 900.0
## Snap distance used to stay glued to terrain while grounded.
@export var floor_snap_length: float = 16.0
## Vertical landing speed before fall damage begins.
@export var fall_damage_speed_threshold: float = 475.0
## Damage dealt per speed unit above the fall threshold.
@export var fall_damage_multiplier: float = 0.35
