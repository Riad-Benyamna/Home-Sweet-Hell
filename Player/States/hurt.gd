extends PlayerState

var hurt_duration: float = 0.5
var hurt_timer: float = 0.0

func EnterState():
	# Animation de hurt
	
	if Player.sprite.sprite_frames.has_animation("hurt"):
		Player.sprite.play("hurt")
	
	# Effet de recul
	Player.velocity.x = -Player.facing * 400  # Recul opposé à la direction
	Player.velocity.y = -300  # Petit saut vers le haut
	
	hurt_timer = 0.0
	print("Entered Hurt State")

func Update(delta):
	hurt_timer += delta
	
	# Appliquer la gravité pendant le hurt
	Player.HandleGravity(delta, Player.GravityFall)
	
	# Ralentir le mouvement horizontal progressivement
	Player.velocity.x = move_toward(Player.velocity.x, 0, 800 * delta)
	
	# Quand le hurt est terminé
	if hurt_timer >= hurt_duration:
		ExitHurt()

func ExitHurt():
	# Revenir à l'état normal selon la situation
	if Player.is_on_floor():
		Player.ChangeState(States.idle)
	else:
		Player.ChangeState(States.fall)

func ExitState():
	hurt_timer = 0.0
	print("Exited Hurt State")
