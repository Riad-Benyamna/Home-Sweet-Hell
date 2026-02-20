extends PlayerState



func EnterState():
	Name = "JumpPeak"


func ExitState():
	pass

func Draw():
	pass


func Update(delta: float):
	Player.ChangeState(States.fall)
	
	
	
	
func HandleAnimations():
	pass
