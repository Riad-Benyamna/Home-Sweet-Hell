extends Node2D
class_name FallingArrow

# Configuration
@export var speed: float = 550
@export var hit_zone: float = 610.0

# Tolérances et scoring
const PERFECT_TOLERANCE: float = 30.0
const GOOD_TOLERANCE: float = 60.0
const BAD_TOLERANCE: float = 80.0

const SCORE_DATA: Array = [
	{"tolerance": PERFECT_TOLERANCE, "points": 20, "message": "Good."},
	{"tolerance": GOOD_TOLERANCE, "points": 10, "message": "Not bad..."},
	{"tolerance": BAD_TOLERANCE, "points": 1, "message": "Mediocre!"}
]

# Animation
const HIT_ANIM_DURATION: float = 0.2
const HIT_ZOOM_SCALE: float = 2
var is_animating: bool = false

# État
var direction: String = ""  # "down", "up", "left", "right"
var counted: bool = false
var is_player: bool = true  # true pour Seb, false pour Olivia

func _ready() -> void:
	
	match direction:
		"down":
			rotation_degrees = 0
		"up":
			rotation_degrees = -180
		"left":
			rotation_degrees = 90
		"right":
			rotation_degrees = -90

func _process(delta: float) -> void:
	
	if is_animating:
		return
	
	position.y += speed * delta
	
	if is_player and not counted:
		_check_input()
	elif not is_player and not counted:
		_check_ai_hit()
	
	# check si la flèche est ratée
	if position.y > hit_zone + BAD_TOLERANCE and not counted:
		_on_missed()
	
	# effacer quand ça sort de l'écran
	if position.y >= 700:
		queue_free()

func _check_input() -> void:
	var action_map: Dictionary = {
		"down": "ui_down",
		"up": "ui_up",
		"left": "ui_left",
		"right": "ui_right"
	}
	
	# check la touche
	if Input.is_action_just_pressed(action_map[direction]):
		_try_hit()
	# si c'est la mauvaise touche
	else:
		for dir in action_map.keys():
			if dir != direction and Input.is_action_just_pressed(action_map[dir]):
				_on_wrong_key()
				break

func _check_ai_hit() -> void:
	# IA olivia
	var distance: float = abs(position.y - hit_zone)
	
	
	if distance <= PERFECT_TOLERANCE:
		_on_successful_ai_hit(20, "Perfect!")
		return

func _try_hit() -> void:
	var distance: float = abs(position.y - hit_zone)
	
	for data in SCORE_DATA:
		var data_dict: Dictionary = data
		if distance <= data_dict["tolerance"]:
			_on_successful_hit(data_dict["points"], data_dict["message"])
			return

func _on_successful_hit(points: int, message: String) -> void:
	counted = true
	get_parent().add_player_score(points, message)
	_play_hit_animation()

func _on_successful_ai_hit(points: int, message: String) -> void:
	counted = true
	_play_hit_animation()

func _on_wrong_key() -> void:
	var distance: float = abs(position.y - hit_zone)
	
	
	for data in SCORE_DATA:
		var data_dict: Dictionary = data
		if distance <= data_dict["tolerance"]:
			get_parent().play_wrong_key_sound()
			get_parent().apply_shake()
			counted = true
			get_parent().add_player_score(-10, "Wrong key!")
			break

func _on_missed() -> void:
	counted = true
	if is_player:
		get_parent().add_player_score(0, "Detestable!")
		get_parent().play_wrong_key_sound()
		get_parent().apply_shake()
func _play_hit_animation() -> void:
	is_animating = true
	
	
	var tween: Tween = create_tween()
	tween.set_parallel(true)  
	
	
	tween.tween_property(self, "scale", Vector2(HIT_ZOOM_SCALE, HIT_ZOOM_SCALE), HIT_ANIM_DURATION)
	
	
	tween.tween_property(self, "modulate:a", 0.0, HIT_ANIM_DURATION)
	
	# Détruire après l'animation
	tween.finished.connect(queue_free)
