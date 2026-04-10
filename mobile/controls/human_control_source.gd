class_name HumanControlSource
extends MobileControlSource

func gather_intent(snapshot: MobileControlSourceSnapshot, delta: float) -> MobileIntent:
	if snapshot == null:
		return MobileIntent.idle()

	var aim_delta: float = 0.0
	var move_direction: int = 0
	if Input.is_action_pressed("angle_increase"):
		aim_delta += snapshot.aim_speed * delta
	if Input.is_action_pressed("angle_decrease"):
		aim_delta -= snapshot.aim_speed * delta
	if Input.is_action_pressed("move_left"):
		move_direction -= 1
	if Input.is_action_pressed("move_right"):
		move_direction += 1

	return MobileIntent.new(
		aim_delta,
		clampi(move_direction, -1, 1),
		Input.is_action_just_pressed("fire"),
		Input.is_action_pressed("fire"),
		Input.is_action_just_released("fire"),
		snapshot.selected_shot_slot
	)
