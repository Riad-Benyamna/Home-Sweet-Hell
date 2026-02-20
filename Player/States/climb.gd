extends PlayerState
@export var climb_scale := Vector2(1.3, 1.3)

func EnterState():
	Name = "Climb"
	Player.velocity = Vector2.ZERO
	Player.sprite.scale = climb_scale

func ExitState():
	Player.sprite.scale = Vector2(1.0, 1.0)

func Update(delta: float):
	# Vérifier si on est toujours sur l'échelle
	if not Player.is_on_ladder():
		if Player.is_on_floor():
			Player.ChangeState(States.idle)
		else:
			Player.ChangeState(States.fall)
		return
	
	# Annuler la gravité et stopper l’inertie
	Player.velocity = Vector2.ZERO
	
	# Mouvement vertical
	var climb_direction = Input.get_axis("up", "down")
	Player.velocity.y = climb_direction * Player.CLIMB_SPEED
	
	# Mouvement horizontal léger
	var move_x = Input.get_axis("left", "right")
	Player.velocity.x = move_x * Player.CLIMB_SPEED * 0.3
	
	# Animation
	if climb_direction != 0:
		Player.sprite.play("climb")
	else:
		Player.sprite.stop()
	
	# Sortir avec saut
	if Player.keyJumpPressed:
		print("Saut pressé, sortie de l'échelle")
		Player.ChangeState(States.fall)
