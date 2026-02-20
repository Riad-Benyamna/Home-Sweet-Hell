extends AnimatableBody2D

@export var bubble_texture: Texture2D
@export var button_texture: Texture2D

# NOUVEAU - Paramètres ajustables
@export_group("Bubble Settings")
@export var bubble_position := Vector2(-500, -50)
@export var bubble_scale := Vector2(0.5, 0.5)

@export_group("Button Settings")
@export var button_position := Vector2(0, -150)  # Position relative à la bulle
@export var button_scale := Vector2(1.5, 1.5)

@onready var detection_area: Area2D = $Area2D

var bubble_sprite: Sprite2D
var message_sprite: Sprite2D
var player_nearby := false
var bubble_visible := false
var bubble_tween: Tween

func _ready() -> void:
	# Création de la bulle
	bubble_sprite = Sprite2D.new()
	bubble_sprite.texture = bubble_texture
	bubble_sprite.position = bubble_position
	bubble_sprite.scale = bubble_scale
	bubble_sprite.visible = true
	bubble_sprite.modulate.a = 0.0
	add_child(bubble_sprite)
	
	# Message dans la bulle
	message_sprite = Sprite2D.new()
	message_sprite.texture = button_texture
	message_sprite.position = button_position  # ← Position ajustable
	message_sprite.scale = button_scale  # ← Scale ajustable
	bubble_sprite.add_child(message_sprite)
	
	# Connexions
	detection_area.body_entered.connect(_on_player_entered)
	detection_area.body_exited.connect(_on_player_exited)

func _process(_delta):
	if player_nearby:
		show_bubble()
	else:
		hide_bubble()

func _on_player_entered(body):
	if body.name == "Seb":
		player_nearby = true

func _on_player_exited(body):
	if body.name == "Seb":
		player_nearby = false

func show_bubble():
	if bubble_visible:
		return
	
	bubble_visible = true
	
	if bubble_tween:
		bubble_tween.kill()
	
	bubble_tween = create_tween()
	bubble_tween.tween_property(
		bubble_sprite,
		"modulate:a",
		1.0,
		0.25
	).set_ease(Tween.EASE_OUT)

func hide_bubble():
	if not bubble_visible:
		return
	
	bubble_visible = false
	
	if bubble_tween:
		bubble_tween.kill()
	
	bubble_tween = create_tween()
	bubble_tween.tween_property(
		bubble_sprite,
		"modulate:a",
		0.0,
		0.25
	).set_ease(Tween.EASE_IN)
