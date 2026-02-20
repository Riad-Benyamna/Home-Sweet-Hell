extends AnimatableBody2D

@export var move_distance := 2000.0  # Distance en pixels vers la droite
@export var move_duration := 1.5    # Temps pour aller de gauche à droite
@export var wait_time := 1
	   # Pause aux extrémités

var start_position: Vector2


func _ready():
	start_position = position
	HandleAnimations()
	start_movement()
	
func HandleAnimations():
	$cloud.play("idle")

func start_movement():
	var tween = create_tween().set_loops()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	# Aller vers la droite
	tween.tween_property(self, "position:x", start_position.x + move_distance, move_duration)
	tween.tween_interval(wait_time)
	
	# Retour vers la gauche
	tween.tween_property(self, "position:x", start_position.x, move_duration)
	tween.tween_interval(wait_time)
