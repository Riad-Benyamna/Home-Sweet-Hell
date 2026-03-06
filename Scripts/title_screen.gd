extends Control
@onready var bg: AnimatedSprite2D = $BG
@onready var title: AnimatedSprite2D = $title
@onready var music: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var Play: AnimatedSprite2D = $Play/AnimatedSprite2D
@onready var fade: ColorRect = $Fade
@onready var Quit: AnimatedSprite2D = $Quit/AnimatedSprite2D
@onready var Continue: Button = $Continue  # The Continue button

var fade_visible := false

func _ready() -> void:
	fade.modulate.a=0.0
	music.play()
	bg.play("default")
	title.play("default")
	Play.play("default")
	Quit.play("default")

	# Show/hide Continue button based on whether saves exist
	# TEMPORARY: Always show for testing
	print("[TitleScreen] Checking for saves...")
	if SaveManager.has_any_save():
		print("[TitleScreen] ✓ Saves found! Showing Continue button")
		Continue.visible = true
		# If you have an AnimatedSprite2D inside Continue, play it:
		if Continue.has_node("AnimatedSprite2D"):
			Continue.get_node("AnimatedSprite2D").play("default")
	else:
		print("[TitleScreen] ✗ No saves found. Hiding Continue button")
		Continue.visible = false

	# TODO: Remove the "always show" logic after testing
	# For now, forcing visible for testing:
	Continue.visible = true
	print("[TitleScreen] → OVERRIDE: Forcing Continue button visible for testing")
func _on_play_pressed():
	_start_fade_out()
	fade_music_and_change_scene("res://scenes//visual_novel.tscn")


func _on_quit_pressed():
	get_tree().quit()


func _on_continue_pressed():
	# Open the save/load menu in LOAD mode
	var save_menu = load("res://scenes/save_load_menu.tscn").instantiate()
	save_menu.mode = 1  # MenuMode.LOAD = 1 (SAVE=0, LOAD=1)
	get_tree().root.add_child(save_menu)


func fade_music_and_change_scene(_scene_path: String):
	var tween := create_tween()
	tween.tween_property(
		music,
		"volume_db",
		-80.0,      # silence
		2         # durée du fondu (secondes)
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.finished.connect(func():
		get_tree().change_scene_to_file("res://scenes/visual_novel.tscn")
	)

func _start_fade_out():
	fade_visible = true
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN)

	tween.tween_property(fade, "modulate:a", 1.0, 2)
