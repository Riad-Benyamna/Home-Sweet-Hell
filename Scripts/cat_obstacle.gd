extends StaticBody2D

@export var dialogue_bubble_texture: Texture2D
@export var custom_font: Font
@export var bubble_size := Vector2(0.8, 0.8)
@export var bubble_position := Vector2(-700, 50)
@export var text_position := Vector2(-200, -250)
@export var answer_line_position := Vector2(-100, -50)
@export var text_color := Color.BLACK
@export var font_size := 10
@export var float_amplitude := 10.0
@export var float_speed := 2.0

# ── Typewriter effect ────────────────────────────────────────
@export var typewriter_speed : float = 20.0   # caractères par seconde

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D
@onready var detection_area = $Area2D

var player_nearby := false
var dialogue_active := false
var waiting_for_answer := false
var riddle_solved := false
var current_sentence_index := 0
var riddle_ready_for_input := false
var in_riddle := false
var player_input := ""

var intro_sentences := [
	"Greetings",
	"My brother’s avarice shall, in time, bar thy path.",
	"Yet that which lies behind me ",
	"May persuade his heart to grant thee passage.",
	"Still, before I lend thee aid,",
	"Uh...Wait what was the script again...?",
	"Oh yeah-",
	"thy worth must first be proven.",
	"Attend now,",
	"And answer well this riddle I propose:"
]

var riddle_question := [
	"'Sapphire eyes in silver fur I bear,'",
	"'And to the girl of golden hair, I stand most dear.'",
	"Speak, then, Who am I?"
]

var current_riddle_index := 0
var correct_answer := "luna"
var correct_response := "Correct, please help thyself."
var wrong_response := "Incorrect."

var bubble_sprite: Sprite2D
var text_label: Label
var answer_display: Label

var base_bubble_position: Vector2
var is_bubble_visible := false

# Typewriter control
var typewriter_tween: Tween

# ────────────────────────────────────────────────
func _ready():
	setup_dialogue_bubble()
	detection_area.body_entered.connect(_on_player_entered)
	detection_area.body_exited.connect(_on_player_exited)

# ────────────────────────────────────────────────
func setup_dialogue_bubble():
	bubble_sprite = Sprite2D.new()
	bubble_sprite.scale = bubble_size
	bubble_sprite.texture = dialogue_bubble_texture
	bubble_sprite.position = bubble_position
	base_bubble_position = bubble_position
	bubble_sprite.modulate.a = 0.0
	add_child(bubble_sprite)

	text_label = Label.new()
	if custom_font:
		text_label.add_theme_font_override("font", custom_font)
	text_label.add_theme_font_size_override("font_size", font_size)
	text_label.add_theme_color_override("font_color", text_color)
	text_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	text_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	text_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	text_label.custom_minimum_size = Vector2(400, 200)
	text_label.position = text_position
	bubble_sprite.add_child(text_label)

	answer_display = Label.new()
	if custom_font:
		answer_display.add_theme_font_override("font", custom_font)
	answer_display.add_theme_font_size_override("font_size", font_size + 8)
	answer_display.add_theme_color_override("font_color", text_color)
	answer_display.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	answer_display.custom_minimum_size = Vector2(200, 50)
	answer_display.position = answer_line_position
	answer_display.visible = false
	bubble_sprite.add_child(answer_display)

	start_floating_animation()

# ────────────────────────────────────────────────
func start_floating_animation():
	var tween = create_tween().set_loops()
	tween.tween_property(bubble_sprite, "position:y", base_bubble_position.y - float_amplitude, float_speed / 2)
	tween.tween_property(bubble_sprite, "position:y", base_bubble_position.y + float_amplitude, float_speed / 2)

# ────────────────────────────────────────────────
func typewriter_reveal(target_label: Label, full_text: String) -> void:
	if typewriter_tween:
		typewriter_tween.kill()
		typewriter_tween = null

	target_label.text = full_text
	target_label.visible_ratio = 0.0

	# Petit fondu d'apparition
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

# ────────────────────────────────────────────────
func skip_typewriter():
	if typewriter_tween:
		typewriter_tween.kill()
		typewriter_tween = null
	
	text_label.visible_ratio = 1.0
	text_label.modulate.a = 1.0

# ────────────────────────────────────────────────
func _process(_delta):
	if not player_nearby:
		return

	if Input.is_action_just_pressed("interact"):
		if typewriter_tween and typewriter_tween.is_running():
			skip_typewriter()
			return

		if dialogue_active:
			if waiting_for_answer:
				return
			if in_riddle:
				next_riddle_line()
			else:
				next_sentence()
		else:
			start_dialogue()

# ────────────────────────────────────────────────
func _input(event):
	# Skip typewriter (touche principale ou accept)
	if event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
		skip_typewriter()
		# On ne return PAS ici → on laisse la touche être traitée si c'est pendant la saisie

	if not waiting_for_answer:
		return

	if not event is InputEventKey or not event.pressed or event.echo:
		return

	var key = OS.get_keycode_string(event.keycode).to_lower()

	if key.length() == 1 and key.is_valid_identifier():
		if player_input.length() < 4:
			player_input += key
			update_answer_display()
	elif event.keycode == KEY_BACKSPACE:
		if player_input.length() > 0:
			player_input = player_input.left(-1)
			update_answer_display()
	elif event.keycode in [KEY_ENTER, KEY_KP_ENTER]:
		if player_input.length() == 4:
			submit_answer()

# ────────────────────────────────────────────────
func start_dialogue():
	dialogue_active = true
	current_sentence_index = 0
	typewriter_reveal(text_label, intro_sentences[0])

# ────────────────────────────────────────────────
func next_sentence():
	current_sentence_index += 1
	if current_sentence_index < intro_sentences.size():
		typewriter_reveal(text_label, intro_sentences[current_sentence_index])
	else:
		start_riddle_lines()

# ────────────────────────────────────────────────
func start_riddle_lines():
	in_riddle = true
	current_riddle_index = 0
	player_input = ""
	answer_display.visible = false
	waiting_for_answer = false
	riddle_ready_for_input = true
	typewriter_reveal(text_label, riddle_question[0])

# ────────────────────────────────────────────────
func next_riddle_line():
	current_riddle_index += 1
	if current_riddle_index < riddle_question.size():
		typewriter_reveal(text_label, riddle_question[current_riddle_index])
	else:
		waiting_for_answer = true
		answer_display.visible = true
		update_answer_display()

# ────────────────────────────────────────────────
func update_answer_display():
	if not riddle_ready_for_input or not waiting_for_answer:
		answer_display.text = ""
		return

	var txt = ""
	for i in range(4):
		if i < player_input.length():
			txt += player_input[i].to_upper() + " "
		else:
			txt += "_ "
	answer_display.text = txt.strip_edges()

# ────────────────────────────────────────────────
func submit_answer():
	answer_display.visible = false
	waiting_for_answer = false

	if player_input.to_lower() == correct_answer:
		typewriter_reveal(text_label, correct_response)
		await get_tree().create_timer(2.0).timeout
		disappear()
	else:
		typewriter_reveal(text_label, wrong_response)
		await get_tree().create_timer(1.6).timeout
		riddle_ready_for_input = false
		start_riddle_lines()

# ────────────────────────────────────────────────
func _on_player_entered(body):
	if body.name == "Seb":
		player_nearby = true
		show_bubble_prompt()

# ────────────────────────────────────────────────
func _on_player_exited(body):
	if body.name == "Seb":
		player_nearby = false
		if not dialogue_active:
			hide_bubble()

# ────────────────────────────────────────────────
func show_bubble_prompt():
	if is_bubble_visible or dialogue_active:
		return
	is_bubble_visible = true
	typewriter_reveal(text_label, "Press E to talk")
	create_tween().tween_property(bubble_sprite, "modulate:a", 1.0, 0.3)

# ────────────────────────────────────────────────
func hide_bubble():
	if not is_bubble_visible:
		return
	is_bubble_visible = false
	create_tween().tween_property(bubble_sprite, "modulate:a", 0.0, 0.3)

# ────────────────────────────────────────────────
func disappear():
	riddle_solved = true
	collision.disabled = true

	var t = create_tween().set_parallel(true)
	t.tween_property(bubble_sprite, "modulate:a", 0.0, 1.0)
	t.tween_property(sprite, "modulate:a", 0.0, 1.0)
	await t.finished
	queue_free()
