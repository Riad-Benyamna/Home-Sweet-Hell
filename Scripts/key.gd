extends Area2D

@onready var sprite = $Sprite2D
@onready var audio_player = $AudioStreamPlayer2D

var collected: bool = false

func _ready():
	body_entered.connect(_on_body_entered)
	
	
	# Flottement
	var float_tween = create_tween().set_loops()
	float_tween.tween_property(self, "position:y", position.y - 15, 0.8).set_ease(Tween.EASE_IN_OUT)
	float_tween.tween_property(self, "position:y", position.y, 0.8).set_ease(Tween.EASE_IN_OUT)

func _on_body_entered(body):
	if body.name == "Seb" and not collected:
		collected = true
		collect()

func collect():
	monitoring = false
	monitorable = false
	
	# Son
	if audio_player:
		audio_player.play()
	
	# Enregistrer la clé
	GameManager.collect_key()
	
	# Animation
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", Vector2(2.0, 2.0), 0.3)
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_property(self, "position:y", position.y - 50, 0.3)
	
	if audio_player:
		await audio_player.finished
	else:
		await tween.finished
	
	queue_free()
