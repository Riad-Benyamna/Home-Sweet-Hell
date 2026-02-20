extends Node2D


func _ready():
	Dialogic.signal_event.connect(_on_dialogic_signal)
	Dialogic.start("Intro")

func _on_dialogic_signal(argument: String):
	if argument == "platformer":
		get_tree().change_scene_to_file("res://scenes/S_level1.tscn")
	if argument == "Rhythm":
		get_tree().change_scene_to_file("res://scenes/rhythm.tscn")
