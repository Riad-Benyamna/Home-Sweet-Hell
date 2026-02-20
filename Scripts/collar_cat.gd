extends StaticBody2D

@export var custom_font: Font
@export var text_position := Vector2(-400, -50)
@export var text_color := Color.BLACK
@export var font_size := 32
@export var typewriter_speed := 20.0

# Objet à donner
@export var item_texture: Texture2D
@export var item_position := Vector2(-300, 100)
@export var item_initial_scale := Vector2(0.5, 0.5)
@export var item_final_scale := Vector2(1.0, 1.0)
@export var next_scene_path := "res://scenes//sophia_path.tscn"

@onready var sprite = $AnimatedSprite2D
@onready var collision = $CollisionShape2D
@onready var detection_area = $Area2D

var player_nearby := false
var dialogue_active := false
var current_sentence_index := 0
var dialogue_finished := false
var is_transitioning := false

var dialogue_sentences := [
	"My child…",
	"You have fulfilled the path we entrusted to you.",
	"Now, the time comes to depart this realm.",
	"The golden-haired girl awaits your coming.",
	"But first,",
	"Take this trinket,",
	"And see that it reaches her hands.",
]

var final_sentence := "Now, Awaken."

var text_label: Label
var item_sprite: Sprite2D
var typewriter_tween: Tween

func _ready():
	sprite.play("idle")
	setup_dialogue()
	detection_area.body_entered.connect(_on_player_entered)
	detection_area.body_exited.connect(_on_player_exited)

func setup_dialogue():
	text_label = Label.new()
	if custom_font:
		text_label.add_theme_font_override("font", custom_font)
	text_label.add_theme_font_size_override("font_size", font_size)
	text_label.add_theme_color_override("font_color", text_color)
	
	text_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	text_label.add_theme_constant_override("shadow_offset_x", 2)
	text_label.add_theme_constant_override("shadow_offset_y", 2)
	
	text_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	text_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	text_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	text_label.custom_minimum_size = Vector2(600, 100)
	text_label.position = text_position - Vector2(300, 50)
	text_label.modulate.a = 0.0
	add_child(text_label)

	item_sprite = Sprite2D.new()
	item_sprite.texture = item_texture
	item_sprite.position = item_position
	item_sprite.modulate.a = 0.0
	item_sprite.scale = item_initial_scale
	add_child(item_sprite)

func typewriter_reveal(target_label: Label, full_text: String) -> void:
	if typewriter_tween:
		typewriter_tween.kill()
		typewriter_tween = null

	target_label.text = full_text
	target_label.visible_ratio = 0.0

	target_label.modulate.a = 0.0
	var fade = create_tween()
	fade.tween_property(target_label, "modulate:a", 1.0, 0.25)

	var char_count = full_text.length()
	if char_count <= 1:
		target_label.visible_ratio = 1.0
		return

	var duration = char_count / typewriter_speed

	typewriter_tween = create_tween()
	typewriter_tween.tween_property(target_label, "visible_ratio", 1.0, duration)\
		.set_trans(Tween.TRANS_LINEAR)\
		.set_ease(Tween.EASE_IN)

func skip_typewriter():
	if typewriter_tween:
		typewriter_tween.kill()
		typewriter_tween = null
	
	text_label.visible_ratio = 1.0
	text_label.modulate.a = 1.0

func _process(_delta):
	if not player_nearby or is_transitioning:
		return

	if Input.is_action_just_pressed("interact"):
		if typewriter_tween and typewriter_tween.is_running():
			skip_typewriter()
			return

		if dialogue_active and not dialogue_finished:
			next_sentence()
		elif not dialogue_active:
			start_dialogue()

func _input(event):
	if is_transitioning:
		return
		
	if event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
		skip_typewriter()

func start_dialogue():
	dialogue_active = true
	current_sentence_index = 0
	typewriter_reveal(text_label, dialogue_sentences[0])

func next_sentence():
	if is_transitioning:
		return
	
	current_sentence_index += 1
	
	if current_sentence_index < dialogue_sentences.size():
		var fade_out = create_tween()
		fade_out.tween_property(text_label, "modulate:a", 0.0, 0.2)
		await fade_out.finished
		
		typewriter_reveal(text_label, dialogue_sentences[current_sentence_index])
	else:
		is_transitioning = true
		give_item()

func give_item():
	dialogue_finished = true
	
	var hide_tween = create_tween()
	hide_tween.tween_property(text_label, "modulate:a", 0.0, 0.5)
	
	await hide_tween.finished
	
	item_sprite.position.y += 100
	
	var item_tween = create_tween()
	item_tween.set_parallel(true)
	
	item_tween.tween_property(item_sprite, "modulate:a", 1.0, 1.0)
	item_tween.tween_property(item_sprite, "position:y", item_position.y, 1.0).set_ease(Tween.EASE_OUT)
	item_tween.tween_property(item_sprite, "scale", item_final_scale, 1.0).set_ease(Tween.EASE_OUT)
	
	await item_tween.finished
	
	var shine_tween = create_tween().set_loops(3)
	shine_tween.tween_property(item_sprite, "modulate", Color.WHITE * 1.5, 0.3)
	shine_tween.tween_property(item_sprite, "modulate", Color.WHITE, 0.3)
	
	await shine_tween.finished
	
	await get_tree().create_timer(1.0).timeout
	
	show_final_message()

func show_final_message():
	typewriter_reveal(text_label, final_sentence)
	
	if typewriter_tween:
		await typewriter_tween.finished
	else:
		await get_tree().create_timer(0.5).timeout
	
	await get_tree().create_timer(2.0).timeout
	
	fade_to_white_and_change_scene()

func fade_to_white_and_change_scene():
	if not is_transitioning:
		return
	
	# Charger le script d'abord
	var fade_script = load("res://scripts/fade_transition.gd")
	if not fade_script:
		print("Error: Could not load fade_transition.gd")
		get_tree().change_scene_to_file(next_scene_path)
		return
	
	# Créer le node de transition
	var transition = Node.new()
	transition.set_script(fade_script)
	get_tree().root.add_child(transition)
	
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 128
	transition.add_child(canvas_layer)
	
	var color_rect = ColorRect.new()
	color_rect.color = Color.WHITE
	color_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	color_rect.modulate.a = 0.0
	canvas_layer.add_child(color_rect)
	
	var audio_players: Array = []
	get_audio_players_recursive(get_tree().root, audio_players)
	
	var original_volumes = {}
	for audio in audio_players:
		if audio.playing:
			original_volumes[audio] = audio.volume_db
	
	var fade_out_tween = get_tree().create_tween()
	fade_out_tween.set_parallel(true)
	
	fade_out_tween.tween_property(color_rect, "modulate:a", 1.0, 2.0)
	
	for audio in original_volumes.keys():
		fade_out_tween.tween_property(audio, "volume_db", -80.0, 2.0)
	
	await fade_out_tween.finished
	
	# Attendre 1 frame pour que le script soit bien initialisé
	await get_tree().process_frame
	
	if not is_instance_valid(transition):
		print("Error: transition node was freed")
		get_tree().change_scene_to_file(next_scene_path)
		return
	
	# Assigner les propriétés
	transition.set("color_rect", color_rect)
	transition.set("next_scene", next_scene_path)
	
	# Lancer la transition
	if transition.has_method("start_transition"):
		transition.call("start_transition")
	else:
		print("Error: start_transition method not found")
		get_tree().change_scene_to_file(next_scene_path)


func get_audio_players_recursive(node: Node, array: Array):
	if node is AudioStreamPlayer or node is AudioStreamPlayer2D or node is AudioStreamPlayer3D:
		array.append(node)
	
	for child in node.get_children():
		get_audio_players_recursive(child, array)

func _on_player_entered(body):
	if body.name == "Seb":
		player_nearby = true
		show_prompt()

func _on_player_exited(body):
	if body.name == "Seb":
		player_nearby = false
		if not dialogue_active:
			hide_prompt()

func show_prompt():
	if dialogue_active or is_transitioning:
		return
	typewriter_reveal(text_label, "Press E to interact")

func hide_prompt():
	var tween = create_tween()
	tween.tween_property(text_label, "modulate:a", 0.0, 0.3)
