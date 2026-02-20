extends Control

@onready var main_text: RichTextLabel = $TW
@onready var warning : RichTextLabel = $Warning
@onready var details_button: Button = $"More details"
@onready var details_text: RichTextLabel = $Details
@onready var fade: ColorRect = $Fade


var details_visible := false
var fade_visible := false

func _ready():
	# Sécurité : tout invisible au départ
	warning.modulate.a = 0.0
	main_text.modulate.a = 0.0
	details_button.modulate.a = 0.0
	details_text.modulate.a = 0.0
	fade.modulate.a=0.0

	_intro_sequence()

func _start_fade_out(next_scene: String):
	fade_visible = true
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN)

	tween.tween_property(fade, "modulate:a", 1.0, 2)
	
	tween.finished.connect(func():
		get_tree().change_scene_to_file(next_scene)
	)



func _intro_sequence():
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	
	tween.tween_property(warning, "modulate:a", 1.0, 0.8)
	tween.tween_interval(1)
	tween.tween_property(main_text, "modulate:a", 1.0, 0.8)
	tween.tween_interval(1)
	tween.tween_property(details_button, "modulate:a", 1.0, 0.6)

func _on_more_details_pressed():
	if details_visible:
		_hide_details()
	else:
		_show_details()

func _show_details():
	details_visible = true
	details_button.text = "Hide details"

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(details_text, "modulate:a", 1.0, 0.6)

func _hide_details():
	details_visible = false
	details_button.text = "More details"

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(details_text, "modulate:a", 0.0, 0.4)

func _on_continue_pressed():
	
	_start_fade_out("res://scenes//title_screen.tscn")
