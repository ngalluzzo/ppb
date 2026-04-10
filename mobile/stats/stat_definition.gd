class_name StatDefinition
extends Resource

@export_category("Survival")
## Total health pool. Unit dies when this reaches zero.
@export var max_health: float = 1000.0
## Reduces incoming damage. Flat reduction applied before percent modifiers.
@export var armor: float = 0.0

@export_category("Movement")
## How far the unit can reposition per turn in pixels.
@export var thrust: float = 100.0
## Affects knockback from explosions and fall damage. Higher = less movement from impacts.
@export var weight: float = 1.0
