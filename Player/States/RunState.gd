extends PlayerState

@export var run_scale := Vector2(1.2, 1.2)

func EnterState():
	Name = "Run"
	# D'abord déplacer, PUIS scaler
	Player.sprite.position = Vector2(0, -50)  # Ajuste cette valeur
	Player.sprite.scale = run_scale

func ExitState():
	Player.sprite.position = Vector2.ZERO
	Player.sprite.scale = Vector2(1.0, 1.0)

func Update(delta: float):
	Player.HorizontalMovement()
	Player.HandleJump()
	Player.HandleFalling()
	HandleAnimations()
	HandleIdle()

func HandleIdle():
	if Player.moveDirectionX == 0:
		Player.ChangeState(States.idle)

func HandleAnimations():
	Player.sprite.play("run")
	Player.HandleFlipH()
