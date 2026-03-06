extends CanvasLayer

@onready var blue_icon: TextureRect = $HBoxContainer/BlueToken
@onready var red_icon: TextureRect = $HBoxContainer/RedToken
@onready var yellow_icon: TextureRect = $HBoxContainer/YellowToken

const DIM = Color(1, 1, 1, 0.5)
const BRIGHT = Color(1, 1, 1, 1.0)

func _ready():
	print("TokenUI _ready called")
	print("blue_icon: ", blue_icon)
	print("red_icon: ", red_icon)
	print("yellow_icon: ", yellow_icon)

	GameManager.token_collected.connect(_on_token_collected)

	# Restore visual state on scene reload (after checkpoint respawn)
	_set_icon(blue_icon, GameManager.blue_token)
	_set_icon(red_icon, GameManager.red_token)
	_set_icon(yellow_icon, GameManager.yellow_token)

func _on_token_collected(color: String):
	match color:
		"blue": _pop(blue_icon)
		"red": _pop(red_icon)
		"yellow": _pop(yellow_icon)

func _set_icon(icon: TextureRect, is_collected: bool):
	icon.modulate = BRIGHT if is_collected else DIM

func _pop(icon: TextureRect):
	icon.modulate = BRIGHT
	var tween = create_tween()
	tween.tween_property(icon, "scale", Vector2(1.4, 1.4), 0.1)
	tween.tween_property(icon, "scale", Vector2(1.0, 1.0), 0.15)
