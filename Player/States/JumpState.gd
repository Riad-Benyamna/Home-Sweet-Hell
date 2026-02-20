extends PlayerState


func EnterState():
	Name = "Jump"
	Player.velocity.y = Player.jumpSpeed


func ExitState():
	pass



func Update(delta: float):
	Player.HandleGravity(delta)
	Player.HorizontalMovement()
	HandleJumptoFall()
	HandleAnimations()
	
	
func HandleJumptoFall():
	if (Player.velocity.y >= 0):
		Player.ChangeState(States.jump_peak)
	if (!Player.keyJump):
		Player.velocity.y *= Player.VariableJumpMultiplier
		Player.ChangeState(States.fall)
		
		
		
func HandleAnimations():
	if Player.sprite.animation != "jump":
		Player.sprite.play("jump")
	Player.HandleFlipH()
