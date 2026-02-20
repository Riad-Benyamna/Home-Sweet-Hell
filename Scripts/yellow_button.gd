extends AnimatableBody2D

signal button_activated

@onready var animated_sprite = $AnimatedSprite2D
@onready var detection_area = $Area2D
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

var is_pressed: bool = false

func _ready():
	animated_sprite.play("unpressed")
	detection_area.body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if not is_pressed and body.name == "Seb":  # Remplacez "Seb" par le nom de votre joueur
		press()

func press():
	is_pressed = true
	audio_player.play()
	animated_sprite.play("pressed")
	button_activated.emit()
	print("Yellow button pressed!")
