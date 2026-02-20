extends Control
@onready var bg: AnimatedSprite2D = $BG
@onready var title: AnimatedSprite2D = $title
@onready var music: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var Play: AnimatedSprite2D = $Play/AnimatedSprite2D
@onready var fade: ColorRect = $Fade
@onready var Quit: AnimatedSprite2D = $Quit/AnimatedSprite2D

var fade_visible := false

func _ready() -> void:
	fade.modulate.a=0.0
	music.play()
	bg.play("default")
	title.play("default")
	Play.play("default")
	Quit.play("default")
func _on_play_pressed():
	_start_fade_out()
	fade_music_and_change_scene("res://scenes//visual_novel.tscn")


func _on_quit_pressed():           
	get_tree().quit()


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
