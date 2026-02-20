extends Area2D

@export_enum("blue", "red", "yellow") var token_color: String = "blue"

@export var player_name: String = "Seb"        # ← Nom du joueur autorisé
@export var token_texture: Texture2D           # ← Sprite du token (optionnel)

@onready var sprite: Sprite2D = $Sprite2D
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

var collected := false


func _ready():
	body_entered.connect(_on_body_entered)

	# Appliquer la texture si fournie
	if token_texture:
		sprite.texture = token_texture

	# Animation de flottement
	var float_tween = create_tween().set_loops()
	float_tween.tween_property(
		self,
		"position:y",
		position.y - 50,
		0.5
	).set_ease(Tween.EASE_IN_OUT)
	float_tween.tween_property(
		self,
		"position:y",
		position.y,
		0.5
	).set_ease(Tween.EASE_IN_OUT)

	# Rotation


func _on_body_entered(body):
	if body.name == player_name and not collected:
		collected = true
		collect()


func collect():
	# Désactiver la détection
	monitoring = false
	monitorable = false

	# Son
	audio_player.play()

	# Enregistrer dans le GameManager
	GameManager.collect_token(token_color)

	# Animation de collecte
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", Vector2(2, 2), 0.3)
	tween.tween_property(self, "modulate:a", 0.0, 0.3)

	# Attendre la fin du son ou de l’animation
	if audio_player:
		await audio_player.finished
	else:
		await tween.finished

	queue_free()
