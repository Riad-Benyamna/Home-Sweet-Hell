extends PlayerState

func EnterState():
	Name = "fall"

func ExitState():
	pass

func Draw():
	pass

func Update(delta: float):
	# Si on est sur une échelle, ce state ne fait RIEN
	if Player.is_on_ladder():
		return

	Player.HandleGravity(delta, Player.GravityFall)
	Player.HorizontalMovement()
	Player.HandleLanding()
	Player.HandleJump()
	Player.HandleJumpBuffer()
	HandleAnimations()

func HandleAnimations():
	Player.sprite.play("fall")
	Player.HandleFlipH()
