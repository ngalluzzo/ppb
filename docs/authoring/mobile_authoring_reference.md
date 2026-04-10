# Mobile Authoring Reference

See also:
- [How to Design a Mobile](./how_to_design_a_mobile.md)
- [Shot Designer Guide](./shot_designer_guide.md)
- [Visual Authoring Guide](./visual_authoring_guide.md)

## Resource Map

| Resource | Owned by | Main purpose |
| --- | --- | --- |
| `MobileDefinition` | unit | unit shell, hit profile, cannon mount, shot slots |
| `CannonDefinition` | unit | launch envelope and muzzle geometry |
| `StatDefinition` | unit | survivability and stat baseline |
| `ShotPattern` | shot slot | projectile count, spacing, stagger, max range |
| `ArcConfig` | shot | gravity, power scaling, wind sensitivity |
| `ProjectileDefinition` | shot | collision radius, visuals, linked impact |
| `ImpactDefinition` | projectile | damage, radius, drill |
| `PhaseLine` | shot | ordered motion/offset phases |
| `PhaseEntry` | phase line | per-phase duration and behavior |

## `MobileDefinition`

### Role

Defines the authored unit shell and links the cannon, stats, and shots.

### Key fields

| Field | Effect |
| --- | --- |
| `name` | Designer-facing identity |
| `cannon_def` | Linked `CannonDefinition` |
| `stat_def` | Linked `StatDefinition` |
| `shot_1`, `shot_2`, `shot_ss` | Linked `ShotPattern` resources |
| `sprite_path` | Sprite folder |
| `sprite_stem` | Explicit filename stem for body/cannon sheets |
| `body_size` | Physical collision footprint |
| `body_zone_radius` | Main hit area |
| `core_zone_radius` | Weak-point size |
| `core_zone_offset` | Weak-point location |
| `cannon_mount_offset` | Cannon child position |

### Notes

- The `Mobile` editor shell draws body, hit zones, cannon mount, and status anchor directly from this resource.
- Set `sprite_stem` explicitly so display-name changes do not break sprite lookup.
- Shared shot resources are allowed, so editing a linked slot may affect multiple mobiles if they share the same asset.

## `CannonDefinition`

### Role

Defines the unit’s aiming and launch envelope.

### Key fields

| Field | Effect |
| --- | --- |
| `min_angle` | Lowest legal elevation |
| `max_angle` | Highest legal elevation |
| `initial_angle` | Starting elevation |
| `min_power` | Minimum launch power |
| `max_power` | Maximum launch power |
| `muzzle_offset` | Launch point relative to the cannon |
| `barrel_sprite_offset` | Visual barrel alignment |

### Notes

- The `Cannon` editor shell draws the aim fan and muzzle marker from this resource.
- The shot designer preview uses the real cannon path, not a separate launch model.

## `ShotPattern`

### Role

Defines the top-level shot behavior for a slot.

### Key fields

| Field | Effect |
| --- | --- |
| `projectile_def` | Linked projectile |
| `arc_config` | Linked arc rules |
| `unit_count` | Projectile count |
| `stagger_delay` | Delay between spawned projectiles |
| `unit_spacing` | Pattern spacing |
| `phase_line` | Linked motion behavior phases |
| `max_range` | Range cap used by projectile/runtime systems |

### Notes

- Change `unit_count`, `unit_spacing`, and `stagger_delay` together.
- Large count changes without spacing/stagger tuning can make the shot unreadable.

## `ArcConfig`

### Role

Defines the ballistic feel of the shot.

### Key fields

| Field | Effect |
| --- | --- |
| `gravity` | Downward acceleration |
| `wind_factor` | Weather sensitivity |
| `power_scale` | Velocity scale from requested power |

### Notes

- `power_scale` and cannon power limits together define practical shot range.
- `gravity` often changes readability more than damage does.

## `ProjectileDefinition`

### Role

Defines how the projectile looks and how large its collision feel is.

### Key fields

| Field | Effect |
| --- | --- |
| `name` | Debug and authoring label |
| `collision_radius` | Projectile collision size |
| `frame_size` | Sprite sheet frame dimensions |
| `frame_count` | Animation frame count |
| `animation_speed` | Animation timing |
| `sprite_sheet` | Projectile texture |
| `impact_def` | Linked `ImpactDefinition` |

### Notes

- Collision feel should match what the sprite reads as, not just what looks cool.
- Big visual sprites with tiny collision radii often feel unfair.
- Author `frame_size` and `frame_count` explicitly whenever the sheet is not the default `16x16 x 4`.

## `ImpactDefinition`

### Role

Defines what happens when the projectile resolves.

### Key fields

| Field | Effect |
| --- | --- |
| `damage` | Base damage |
| `radius` | Splash radius |
| `drill_power` | Terrain drilling strength |

### Notes

- If the shot only feels good because the radius is huge, revisit arc and projectile design first.

## `PhaseLine` and `PhaseEntry`

### Role

Defines ordered behavior phases for projectile visual/behavior offsets.

### Key fields

| Resource | Field | Effect |
| --- | --- | --- |
| `PhaseLine` | `phases` | Ordered list of `PhaseEntry` resources |
| `PhaseEntry` | `duration` | How long the phase lasts |
| `PhaseEntry` | `behavior` | Linked behavior resource |

### Notes

- Tune the shot so it works without fancy phase behavior first.
- Use phase behavior to add identity, not to rescue a weak base shot.

## Runtime And Tooling Anchors

| Node / tool | Use |
| --- | --- |
| `Mobile` | visualize body footprint, hit zones, cannon mount, status anchor |
| `Cannon` | visualize aim band, muzzle, and preview shot event construction |
| `BattleSystem` | exact preview host |
| `Shot Designer` addon | staged shot editing with embedded exact preview |

## Shared Resource Warning

The authoring model allows linked resources to be intentionally shared. Before pressing `Apply` in the Shot Designer, check the shown resource paths and confirm you are editing the assets you actually intend to change.
