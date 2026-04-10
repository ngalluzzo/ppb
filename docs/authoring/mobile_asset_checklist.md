# Mobile Asset Checklist

See also:
- [Visual Authoring Guide](./visual_authoring_guide.md)
- [How to Design a Mobile](./how_to_design_a_mobile.md)

Use this before calling a new mobile visually complete.

## MobileDefinition

- `sprite_path` points at the correct folder.
- `sprite_stem` is set explicitly.
- `body_size` matches the intended silhouette footprint.
- `body_zone_radius` and `core_zone_*` have been checked against the art.
- `cannon_mount_offset` has been validated in the editor.

## Body Strips

- `body_idle` exists.
- `body_walk` exists.
- `body_fire` exists.
- `body_hit` exists.
- `body_die` exists.
- `body_charge` exists or is intentionally deferred.
- `body_aim` exists or is intentionally deferred.
- all body strips use `48x48` cells.
- all body strips are horizontal single-row sheets.

## Cannon Strips

- `cannon_idle` exists.
- `cannon_fire` exists.
- `cannon_charge` exists or is intentionally deferred.
- all cannon strips use `32x32` cells.
- the visible muzzle lines up with the authored muzzle offset.

## Projectile Assets

- each shot projectile has a `ProjectileDefinition`.
- each projectile definition sets `sprite_sheet`.
- each projectile definition sets `frame_size`.
- each projectile definition sets `frame_count`.
- projectile collision radius roughly matches the visible projectile.

## In-Editor Validation

- `Mobile` gizmos show a believable body footprint.
- core and body hit zones look fair.
- `Cannon` gizmos show a believable muzzle and aim fan.
- Shot Designer preview launches from the expected muzzle point.
- low, medium, and high power all read clearly.
- both facing directions look correct.

## Cleanliness

- no `.DS_Store` or similar junk files in asset folders.
- no unused placeholder strips unless documented.
- Shot Designer resource paths match the assets you intend to edit.

