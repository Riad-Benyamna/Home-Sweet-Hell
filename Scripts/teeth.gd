extends Node2D

@export var move_distance := 500.0  # Distance en pixels vers la droite
@export var move_duration := 0.5    # Temps pour aller de gauche à droite
@export var wait_time := 1.0        # Pause aux extrémités

# Paramètres du shake
@export var shake_intensity := 12.0  # Intensité du tremblement
@export var shake_duration := 0.5   # Durée du shake avant de bouger

var start_position: Vector2
var is_shaking := false

func _ready():
	start_position = position
	start_movement()

func start_movement():
	var tween = create_tween().set_loops()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	# Shake avant d'aller à droite
	tween.tween_callback(shake_before_move)
	tween.tween_interval(shake_duration)
	
	# Aller vers la droite
	tween.tween_property(self, "position:x", start_position.x + move_distance, move_duration)
	tween.tween_interval(wait_time)
	
	# Shake avant de retourner à gauche
	tween.tween_callback(shake_before_move)
	tween.tween_interval(shake_duration)
	
	# Retour vers la gauche
	tween.tween_property(self, "position:x", start_position.x, move_duration)
	tween.tween_interval(wait_time)

func shake_before_move():
	if is_shaking:
		return
	
	is_shaking = true
	var shake_tween = create_tween()
	var shake_count = int(shake_duration / 0.05)  # Nombre de secousses
	
	for i in range(shake_count):
		var random_offset = Vector2(
			randf_range(-shake_intensity, shake_intensity),
			randf_range(-shake_intensity, shake_intensity)
		)
		shake_tween.tween_property(self, "position", position + random_offset, 0.05)
	
	# Revenir à la position de départ du shake
	shake_tween.tween_callback(func(): is_shaking = false)
