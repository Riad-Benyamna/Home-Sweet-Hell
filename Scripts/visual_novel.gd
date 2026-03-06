extends Node2D

var _save_ui: CanvasLayer
var _save_menu_canvas: CanvasLayer = null

func _ready():
	# Enable saving when in VN mode
	SaveManager.enable_saving()

	Dialogic.signal_event.connect(_on_dialogic_signal)

	# Add a visible Save button in the top-right corner (layer 100 = on top of Dialogic UI)
	_save_ui = CanvasLayer.new()
	_save_ui.layer = 100
	add_child(_save_ui)

	var save_btn = Button.new()
	save_btn.text = "Save"
	save_btn.size = Vector2(100, 40)
	save_btn.position = Vector2(1490, 10)  # Top-right corner (adjust if your resolution differs)
	save_btn.pressed.connect(_open_save_menu)
	_save_ui.add_child(save_btn)

	if SaveManager.pending_load_slot != "":
		# Load from save: start Dialogic first to create the layout nodes,
		# then wait one frame for them to be ready, then load the saved state.
		var slot = SaveManager.pending_load_slot
		SaveManager.pending_load_slot = ""
		print("[VisualNovel] Loading from save slot: " + slot)
		Dialogic.start("Intro")          # Creates the Dialogic layout
		await get_tree().process_frame   # Wait for layout nodes to initialise
		Dialogic.Save.load(slot)         # Restore saved state (overrides Intro)
	elif not Dialogic.current_timeline:
		print("[VisualNovel] Starting new game from Intro timeline")
		Dialogic.start("Intro")
	else:
		print("[VisualNovel] Resuming from save - Timeline: " + str(Dialogic.current_timeline))

func _open_save_menu():
	# If menu is already open, close it (ESC toggles)
	if is_instance_valid(_save_menu_canvas):
		_save_menu_canvas.queue_free()
		_save_menu_canvas = null
		Dialogic.paused = false
		return

	if not SaveManager.saving_enabled:
		return
	Dialogic.paused = true
	var canvas = CanvasLayer.new()
	canvas.layer = 100
	get_tree().root.add_child(canvas)
	var save_menu = load("res://scenes/save_load_menu.tscn").instantiate()
	save_menu.mode = 0  # MenuMode.SAVE = 0
	canvas.add_child(save_menu)
	_save_menu_canvas = canvas
	# Clear reference when menu closes itself (e.g. Back button)
	canvas.tree_exited.connect(func(): _save_menu_canvas = null)

func _unhandled_key_input(event):
	# Press ESC to open save menu during VN
	if event.is_action_pressed("open_save_menu"):
		_open_save_menu()
		get_viewport().set_input_as_handled()

func _on_dialogic_signal(argument: String):
	if argument == "open_save_menu":
		# Open save menu when triggered from timeline
		_open_save_menu()
	elif argument == "platformer":
		# Disable saving before entering gameplay
		SaveManager.disable_saving()
		get_tree().change_scene_to_file("res://scenes/S_level1.tscn")
	elif argument == "Rhythm":
		# Disable saving before entering gameplay
		SaveManager.disable_saving()
		get_tree().change_scene_to_file("res://scenes/rhythm.tscn")
