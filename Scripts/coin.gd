extends Area2D

@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
@export var value := 1
var collected: bool = false
var coin_id: String = ""

func _ready():
	coin_id = str(get_path())

	# Already collected before this respawn — stay gone
	if GameManager.is_coin_collected(coin_id):
		queue_free()
		return

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
	GameManager.register_coin_collected(coin_id)
	GameManager.add_coins(value)
	
	var col_shape = $CollisionShape2D	
	col_shape.disabled = true
	
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.2)
	await audio_stream_player_2d.finished
	tween.tween_callback(queue_free)
