extends PlayerState

func EnterState():
	Name = "Idle"


func ExitState():
	pass

func Draw():
	pass


func Update(delta: float):
	Player.HandleFalling()
	Player.HandleJump()
	Player.HorizontalMovement()
	if (Player.moveDirectionX != 0):
		Player.ChangeState(States.run)
	HandleAnimations()
func HandleAnimations():
	Player.sprite.play("idle")
	Player.HandleFlipH()
