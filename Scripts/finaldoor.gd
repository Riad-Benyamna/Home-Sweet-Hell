extends Area2D

@export var next_level_scene: String = "res://scenes//level_2.tscn"
@export var bubble_texture: Texture2D
@export var no_key_message_texture: Texture2D
@export var can_open_message_texture: Texture2D
@export var music_player: AudioStreamPlayer

@onready var sprite: Sprite2D = $Sprite2D
@onready var detection_area: Area2D = $Area2D

var bubble_sprite: Sprite2D
var message_sprite: Sprite2D

var player_nearby := false
var is_open := false

var bubble_visible := false
var bubble_tween: Tween


func _ready():
	# Création de la bulle
	bubble_sprite = Sprite2D.new()
	bubble_sprite.texture = bubble_texture
	bubble_sprite.position = Vector2(500, -50)
	bubble_sprite.visible = true
	bubble_sprite.modulate.a = 0.0
	add_child(bubble_sprite)

	# Message dans la bulle
	message_sprite = Sprite2D.new()
	bubble_sprite.add_child(message_sprite)

	# Connexions
	detection_area.body_entered.connect(_on_player_entered)
	detection_area.body_exited.connect(_on_player_exited)


func _process(_delta):
	if is_open:
		return

	if player_nearby:
		if GameManager.has_the_key():
			message_sprite.texture = can_open_message_texture
			show_bubble()

			if Input.is_action_just_pressed("ui_accept"):
				open_door()
		else:
			message_sprite.texture = no_key_message_texture
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
	
func fade_music_and_change_scene(scene_path: String):
	var tween := create_tween()
	tween.tween_property(
		music_player,
		"volume_db",
		-80.0,      # silence
		2         # durée du fondu (secondes)
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	tween.finished.connect(func():
		get_tree().change_scene_to_file(next_level_scene)
	)


func open_door():
	if is_open:
		return

	is_open = true
	hide_bubble()

	print("Opening door to next level!")

	# Désactiver l’Area
	monitoring = false
	monitorable = false

	# Animation d’ouverture
	var tween = create_tween()
	tween.set_parallel(true)

	FadeManager.fade_out(2)
	fade_music_and_change_scene(next_level_scene)
	await FadeManager.fade_out(2)
	FadeManager.fade_in(3)
	
