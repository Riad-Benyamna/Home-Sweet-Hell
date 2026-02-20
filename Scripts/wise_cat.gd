extends StaticBody2D

@export var bubble_texture: Texture2D
@export var message_texture: Texture2D
@export var bubble_offset: Vector2 = Vector2(-300, -50)
@export var bubble_scale = Vector2(0.4, 0.4)

@onready var collision = $CollisionShape2D
@onready var sprite: AnimatedSprite2D = $wisecat
@onready var detection_area = $Area2D
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var meow : AudioStreamPlayer2D = $AudioStreamPlayer2D2


var bubble_sprite: Sprite2D
var player_nearby := false
var is_unlocked := false
var is_bubble_visible := false
var all_tokens := false   # ← NOUVEAU


func _ready():
	sprite.play("idle")

	# Création de la bulle
	bubble_sprite = Sprite2D.new()
	bubble_sprite.texture = bubble_texture
	bubble_sprite.visible = true
	bubble_sprite.modulate.a = 0.0
	bubble_sprite.position = bubble_offset
	bubble_sprite.scale = bubble_scale
	add_child(bubble_sprite)

	# Message
	if message_texture:
		var message = Sprite2D.new()
		message.texture = message_texture
		bubble_sprite.add_child(message)

	# Connexions
	detection_area.body_entered.connect(_on_player_entered)
	detection_area.body_exited.connect(_on_player_exited)
	GameManager.all_tokens_collected.connect(_on_all_tokens_collected)


func _process(_delta):
	if is_unlocked:
		return

	# CONDITION CLÉ
	if player_nearby and all_tokens:
		unlock_passage()
	elif player_nearby and not all_tokens:
		show_bubble()
	else:
		hide_bubble()


func _on_player_entered(body):
	if body.name == "Seb":
		player_nearby = true
		meow.play()


func _on_player_exited(body):
	if body.name == "Seb":
		player_nearby = false


func _on_all_tokens_collected():
	all_tokens = true   # ← On mémorise seulement


func show_bubble():
	if is_bubble_visible:
		return

	is_bubble_visible = true
	var tween = create_tween()
	tween.tween_property(bubble_sprite, "modulate:a",0.8, 0.4).set_ease(Tween.EASE_OUT)


func hide_bubble():
	if not is_bubble_visible:
		return

	is_bubble_visible = false
	var tween = create_tween()
	tween.tween_property(bubble_sprite, "modulate:a", 0.0, 0.3).set_ease(Tween.EASE_IN)


func unlock_passage():
	if is_unlocked:
		return

	is_unlocked = true
	hide_bubble()
	audio_player.play()
	print("Secret passage unlocked!")
	sprite.play("awaken")
	var tween = create_tween()
	tween.set_parallel(true)
	collision.disabled = true
	tween.tween_property(sprite, "modulate:a", 0.0, 0.5)

	await tween.finished
	queue_free()
