extends Node2D


func _ready():
	# Enable saving when in VN mode
	SaveManager.enable_saving()

	Dialogic.signal_event.connect(_on_dialogic_signal)

	# Check if we should load from a save or start fresh
	# If Dialogic is already running (loaded from save), don't start Intro
	if not Dialogic.current_timeline:
		Dialogic.start("Intro")

func _on_dialogic_signal(argument: String):
	if argument == "platformer":
		# Disable saving before entering gameplay
		SaveManager.disable_saving()
		get_tree().change_scene_to_file("res://scenes/S_level1.tscn")
	if argument == "Rhythm":
		# Disable saving before entering gameplay
		SaveManager.disable_saving()
		get_tree().change_scene_to_file("res://scenes/rhythm.tscn")
