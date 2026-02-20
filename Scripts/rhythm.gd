extends Node2D

# Scène de flèche (une seule maintenant!)
var falling_arrow_scene: PackedScene = preload("res://scenes/arrow.tscn")
@onready var camera = $Camera2D
@onready var wrong_key_sound: AudioStreamPlayer2D = $WrongKeySound
@onready var fade_overlay: ColorRect = $FadeOverlay  # Ajouter ce node
signal dialogue_transition_finished

# Configuration MIDI -> Direction
const MIDI_MAPPING: Dictionary = {
	"down": {"start": 38, "end": 55, "step": 2},
	"up": {"start": 55, "end": 72, "step": 2},
	"left": {"start": 39, "end": 72, "step": 2},
	"right": {"start": 56, "end": 73, "step": 2}
}

@onready var seb_lanes: Dictionary = {
	"down": $"Seb Lanes/bas",
	"up": $"Seb Lanes/haut",
	"left": $"Seb Lanes/gauche",
	"right": $"Seb Lanes/droite"
}

@onready var olivia_lanes: Dictionary = {
	"down": $"Olivia Lanes/bas",
	"up": $"Olivia Lanes/haut",
	"left": $"Olivia Lanes/gauche",
	"right": $"Olivia Lanes/droite"
}

# UI
@onready var score_label: Label = $Score
@onready var comment_label: Label = $Comment
@onready var error_bar: ProgressBar = $ErrorBar
@onready var game_over_screen: Control = $GameOverScreen

# MIDI 1
@onready var seb_midi: MidiPlayer = $SebPart
@onready var olivia_midi: MidiPlayer = $OliviaPart
@onready var music_player: AudioStreamPlayer2D = $Perfect

# MIDI 2
@onready var seb_midi2: MidiPlayer = $SebPart2
@onready var olivia_midi2: MidiPlayer = $OliviaPart2
@onready var music_player2: AudioStreamPlayer2D = $Hysteria

# MIDI 3
@onready var seb_midi3: MidiPlayer = $SebPart3
@onready var olivia_midi3: MidiPlayer = $OliviaPart3
@onready var music_player3: AudioStreamPlayer2D = $Say 

# Comment
var comment_fade_timer: float = 0.0
const COMMENT_DISPLAY_TIME: float = 0.1
const COMMENT_FADE_TIME: float = 0.1

# State
var seb_score: int = 0
var olivia_score: int = 0

# Mistakes
var error_value: float = 0.0
const MAX_ERROR: float = 100.0
const ERROR_DECREASE_RATE: float = 5
const ERROR_WRONG_KEY: float = 5
const ERROR_MISS: float = 10.0

var is_game_over: bool = false

# Screen shake
@onready var rand = RandomNumberGenerator.new()
@export var RANDOM_SHAKE_STRENGTH: float = 10.0
@export var SHAKE_DECAY_RATE: float = 5.0
var shake_strength: float = 0.0

# Screen shaking when she starts losing her shi
var song3_shake_active: bool = false
var song3_shake_progress: float = 0.0
const SONG3_SHAKE_START_TIME: float = 60.0  
const SONG3_SHAKE_DURATION: float = 12.0    
const SONG3_SHAKE_MAX_STRENGTH: float = 40.0  

# Transition
const FADE_DURATION: float = 2.0 

# Musiques
static var current_song: int = 1 # 1 = Perfect, 2 = Hysteria, 3 = Say
var song_transition_done: bool = false
var song2_transition_done: bool = false
var is_in_dialogue: bool = false

func _ready() -> void:
	
	rand.randomize()
	
	
	error_bar.min_value = 0
	error_bar.max_value = MAX_ERROR
	error_bar.value = 0
	
	if game_over_screen:
		game_over_screen.visible = false
	
	
	if fade_overlay:
		fade_overlay.modulate.a = 0.0
		fade_overlay.visible = true
	
	update_score_labels()
	comment_label.text = ""
	
	await get_tree().create_timer(1).timeout
	
	
	_start_song(current_song)
	
	_setup_static_arrows()

func _start_song(song_number: int) -> void:
	if song_number == 1:
		# 1
		seb_midi.connect("midi_event", _on_seb_midi_event)
		olivia_midi.connect("midi_event", _on_olivia_midi_event)
		music_player.connect("finished", _on_song1_finished)
		
		seb_midi.play()
		olivia_midi.play()
		await get_tree().create_timer(1.82).timeout
		music_player.play()
	
	elif song_number == 2:
		# 2
		seb_midi2.connect("midi_event", _on_seb_midi2_event)
		olivia_midi2.connect("midi_event", _on_olivia_midi2_event)
		music_player2.connect("finished", _on_song2_finished)
		
		Dialogic.signal_event.connect(_on_dialogic_signal)
		Dialogic.start("Rhythm Dialogue")
		await dialogue_transition_finished
		Dialogic.signal_event.disconnect(_on_dialogic_signal)
		
		seb_midi2.play()
		olivia_midi2.play()
		await get_tree().create_timer(1.82).timeout
		music_player2.play()
	
	elif song_number == 3:
		# 3
		seb_midi3.connect("midi_event", _on_seb_midi3_event)
		olivia_midi3.connect("midi_event", _on_olivia_midi3_event)
		music_player3.connect("finished", _on_song3_finished)  # Connexion du signal finished
		
		Dialogic.signal_event.connect(_on_dialogic_signal)
		Dialogic.start("Rhythm Dialogue 2")
		await dialogue_transition_finished
		Dialogic.signal_event.disconnect(_on_dialogic_signal)
		
		seb_midi3.play()
		olivia_midi3.play()
		await get_tree().create_timer(1.82).timeout
		music_player3.play()
		
		# lost it
		_start_song3_shake_timer()

func _start_song3_shake_timer() -> void:
	
	await get_tree().create_timer(SONG3_SHAKE_START_TIME).timeout
	
	if is_game_over:
		return
	
	song3_shake_active = true
	song3_shake_progress = 0.0

func _on_song1_finished() -> void:
	if song_transition_done:
		return
	
	song_transition_done = true
	is_in_dialogue = true
	
	# stop music
	seb_midi.stop()
	olivia_midi.stop()
	
	
	Dialogic.signal_event.connect(_on_dialogic_signal)
	
	Dialogic.start("Rhythm Dialogue")
	
	await dialogue_transition_finished
	
	Dialogic.signal_event.disconnect(_on_dialogic_signal)
	
	# Save
	current_song = 2
	is_in_dialogue = false
	
	await get_tree().create_timer(1.0).timeout
	
	# start 2
	seb_midi2.connect("midi_event", _on_seb_midi2_event)
	olivia_midi2.connect("midi_event", _on_olivia_midi2_event)
	music_player2.connect("finished", _on_song2_finished)
	
	seb_midi2.play()
	olivia_midi2.play()
	await get_tree().create_timer(1.82).timeout
	music_player2.play()

func _on_song2_finished() -> void:
	if song2_transition_done:
		return
	
	song2_transition_done = true
	is_in_dialogue = true
	
	seb_midi2.stop()
	olivia_midi2.stop()
	
	
	
	Dialogic.signal_event.connect(_on_dialogic_signal)
	Dialogic.start("Rhythm Dialogue 2")
	await dialogue_transition_finished
	Dialogic.signal_event.disconnect(_on_dialogic_signal)
	
	current_song = 3
	is_in_dialogue = false
	
	await get_tree().create_timer(1.0).timeout
	
	# start 3
	seb_midi3.connect("midi_event", _on_seb_midi3_event)
	olivia_midi3.connect("midi_event", _on_olivia_midi3_event)
	music_player3.connect("finished", _on_song3_finished)
	
	seb_midi3.play()
	olivia_midi3.play()
	await get_tree().create_timer(1.82).timeout
	music_player3.play()
	
	# start shake
	_start_song3_shake_timer()

func _on_song3_finished() -> void:
	
	
	# stop midi
	seb_midi3.stop()
	olivia_midi3.stop()
	song3_shake_active = false  # stop shake
	camera.offset = Vector2.ZERO  
	
	# Faire le fondu au noir
	await _fade_to_black()
	
	
	get_tree().change_scene_to_file("res://scenes/olivia_path.tscn")

func _fade_to_black() -> void:
	if not fade_overlay:
		return
	
	var tween: Tween = create_tween()
	tween.tween_property(fade_overlay, "modulate:a", 1.0, FADE_DURATION)
	await tween.finished

func _on_dialogic_signal(argument: String) -> void:
	if argument == "transition_finished":
		dialogue_transition_finished.emit()

func _process(delta: float) -> void:
	if is_game_over:
		return
	
	if comment_fade_timer > 0.0:
		comment_fade_timer -= delta
		
		if comment_fade_timer <= COMMENT_FADE_TIME:
			comment_label.modulate.a = comment_fade_timer / COMMENT_FADE_TIME
		
		if comment_fade_timer <= 0.0:
			comment_label.text = ""
			comment_label.modulate.a = 1.0
	
	if error_value > 0:
		error_value -= ERROR_DECREASE_RATE * delta
		error_value = max(0, error_value)
		update_error_bar()
	
	if song3_shake_active:
		song3_shake_progress += delta
		
		if song3_shake_progress <= SONG3_SHAKE_DURATION:
			#shake strength calculation
			var shake_ratio: float = pow(song3_shake_progress, 2.0) / pow(SONG3_SHAKE_DURATION, 2.0)
			var current_shake: float = SONG3_SHAKE_MAX_STRENGTH * shake_ratio
			camera.offset = Vector2(
				rand.randf_range(-current_shake, current_shake),
				rand.randf_range(-current_shake, current_shake)
			)
		else:
			song3_shake_active = false
			camera.offset = Vector2.ZERO
	
	# Mistake shake
	elif shake_strength > 0:
		shake_strength = lerp(shake_strength, 0.0, SHAKE_DECAY_RATE * delta)
		camera.offset = get_random_offset()
	else:
		camera.offset = Vector2.ZERO

func _setup_static_arrows() -> void:
	# Seb
	if has_node("Seb Arrows"):
		for arrow in $"Seb Arrows".get_children():
			arrow.visible = true
	
	# Olivia
	if has_node("Olivia Arrows"):
		for arrow in $"Olivia Arrows".get_children():
			arrow.visible = true

# MIDI stuff
# MIDI 1

func _on_seb_midi_event(channel: Variant, event: Variant) -> void:
	if is_game_over:
		return
	
	if not (event is SMF.MIDIEventNoteOn and event.velocity > 0):
		return
	
	var note: int = event.note
	
	for direction in MIDI_MAPPING.keys():
		var mapping: Dictionary = MIDI_MAPPING[direction]
		if _is_note_in_range(note, mapping["start"], mapping["end"], mapping["step"]):
			spawn_arrow(direction, true)
			break

func _on_olivia_midi_event(channel: Variant, event: Variant) -> void:
	if is_game_over:
		return
	
	if not (event is SMF.MIDIEventNoteOn and event.velocity > 0):
		return
	
	var note: int = event.note
	
	for direction in MIDI_MAPPING.keys():
		var mapping: Dictionary = MIDI_MAPPING[direction]
		if _is_note_in_range(note, mapping["start"], mapping["end"], mapping["step"]):
			spawn_arrow(direction, false)
			break

# MIDI 2

func _on_seb_midi2_event(channel: Variant, event: Variant) -> void:
	if is_game_over:
		return
	
	if not (event is SMF.MIDIEventNoteOn and event.velocity > 0):
		return
	
	var note: int = event.note
	
	for direction in MIDI_MAPPING.keys():
		var mapping: Dictionary = MIDI_MAPPING[direction]
		if _is_note_in_range(note, mapping["start"], mapping["end"], mapping["step"]):
			spawn_arrow(direction, true)
			break

func _on_olivia_midi2_event(channel: Variant, event: Variant) -> void:
	if is_game_over:
		return
	
	if not (event is SMF.MIDIEventNoteOn and event.velocity > 0):
		return
	
	var note: int = event.note
	
	for direction in MIDI_MAPPING.keys():
		var mapping: Dictionary = MIDI_MAPPING[direction]
		if _is_note_in_range(note, mapping["start"], mapping["end"], mapping["step"]):
			spawn_arrow(direction, false)
			break

# MIDI 3

func _on_seb_midi3_event(channel: Variant, event: Variant) -> void:
	if is_game_over:
		return
	
	if not (event is SMF.MIDIEventNoteOn and event.velocity > 0):
		return
	
	var note: int = event.note
	
	for direction in MIDI_MAPPING.keys():
		var mapping: Dictionary = MIDI_MAPPING[direction]
		if _is_note_in_range(note, mapping["start"], mapping["end"], mapping["step"]):
			spawn_arrow(direction, true)
			break

func _on_olivia_midi3_event(channel: Variant, event: Variant) -> void:
	if is_game_over:
		return
	
	if not (event is SMF.MIDIEventNoteOn and event.velocity > 0):
		return
	
	var note: int = event.note
	
	for direction in MIDI_MAPPING.keys():
		var mapping: Dictionary = MIDI_MAPPING[direction]
		if _is_note_in_range(note, mapping["start"], mapping["end"], mapping["step"]):
			spawn_arrow(direction, false)
			break

# --- Utilitaires ---

func _is_note_in_range(note: int, start: int, end: int, step: int) -> bool:
	if note < start or note >= end:
		return false
	return (note - start) % step == 0

func spawn_arrow(direction: String, is_player: bool) -> void:
	if is_game_over:
		return
	
	var arrow: FallingArrow = falling_arrow_scene.instantiate()
	arrow.direction = direction
	arrow.is_player = is_player
	
	if is_player:
		arrow.position = seb_lanes[direction].position
	else:
		arrow.position = olivia_lanes[direction].position
	
	add_child(arrow)

# Score

func add_player_score(points: int, message: String = "") -> void:
	if is_game_over:
		return
	
	seb_score += points
	update_score_labels()
	
	# Gérer les erreurs
	if message == "Wrong key!":
		add_error(ERROR_WRONG_KEY)
	elif message == "Detestable!":
		add_error(ERROR_MISS)
	
	if message != "":
		show_comment(message)

func add_ai_score(points: int) -> void:
	if is_game_over:
		return
	
	olivia_score += points

func update_score_labels() -> void:
	score_label.text = "Score: %d" % seb_score

func show_comment(message: String) -> void:
	comment_label.text = message
	comment_label.modulate.a = 1.0
	comment_fade_timer = COMMENT_DISPLAY_TIME + COMMENT_FADE_TIME

func play_wrong_key_sound() -> void:
	wrong_key_sound.play()

# Mistakes

func add_error(amount: float) -> void:
	error_value += amount
	error_value = min(error_value, MAX_ERROR)
	update_error_bar()
	
	if error_value >= MAX_ERROR:
		trigger_game_over()

func update_error_bar() -> void:
	error_bar.value = error_value
	
	var error_ratio: float = error_value / MAX_ERROR
	if error_ratio < 0.5:
		error_bar.modulate = Color(1, 1, 1)
	elif error_ratio < 0.75:
		error_bar.modulate = Color(1, 0.8, 0)
	else:
		error_bar.modulate = Color(1, 0, 0)

#game over stuff
func trigger_game_over() -> void:
	is_game_over = true
	wrong_key_sound.play()
	song3_shake_active = false 
	
	# Stop everything yknow
	seb_midi.stop()
	olivia_midi.stop()
	music_player.stop()
	seb_midi2.stop()
	olivia_midi2.stop()
	music_player2.stop()
	seb_midi3.stop()
	olivia_midi3.stop()
	music_player3.stop()
	
	
	for child in get_children():
		if child is FallingArrow:
			child.queue_free()
	
	if game_over_screen:
		game_over_screen.visible = true

func _on_restart_button_pressed() -> void:
	get_tree().reload_current_scene()

# Screen Shake 

func get_random_offset() -> Vector2:
	return Vector2(
		rand.randf_range(-shake_strength, shake_strength),
		rand.randf_range(-shake_strength, shake_strength)
	)

func apply_shake() -> void:
	shake_strength = RANDOM_SHAKE_STRENGTH
