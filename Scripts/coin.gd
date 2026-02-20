extends Area2D

@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
@export var value := 1
var collected: bool = false

func _ready():
	body_entered.connect(_on_body_entered)
	
	var tween = create_tween().set_loops()
	tween.tween_property(self, "position:y", position.y - 15, 0.5)
	tween.tween_property(self, "position:y", position.y, 0.5)

func _on_body_entered(body):
	if body.name == "Seb" and not collected:
		collected = true
		audio_stream_player_2d.play()
		collect()

func collect():
	monitoring = false
	monitorable = false
	
	# Ajouter les pièces au GameManager
	GameManager.add_coins(value)  # ← NOUVELLE LIGNE
	
	var col_shape = $CollisionShape2D	
	col_shape.disabled = true
	
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.2)
	await audio_stream_player_2d.finished
	tween.tween_callback(queue_free)
