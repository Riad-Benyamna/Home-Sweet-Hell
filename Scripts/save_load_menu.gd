extends Control

## Save/Load menu UI
## Shows 4 slots: Autosave + 3 manual saves
## Similar to DDLC save system

enum MenuMode { SAVE, LOAD }

@export var mode: MenuMode = MenuMode.LOAD

@onready var slot_container: VBoxContainer = $Panel/MarginContainer/VBoxContainer/SlotContainer
@onready var title_label: Label = $Panel/MarginContainer/VBoxContainer/TitleLabel
@onready var back_button: Button = $Panel/MarginContainer/VBoxContainer/BackButton

# Slot button references
var slot_buttons: Array[Button] = []

func _ready():
	setup_ui()
	refresh_slots()
	back_button.pressed.connect(_on_back_pressed)

func setup_ui():
	# Set title based on mode
	if mode == MenuMode.SAVE:
		title_label.text = "Save Game"
	else:
		title_label.text = "Load Game"

	# Create slot buttons
	create_slot_buttons()

func create_slot_buttons():
	# Clear existing buttons
	for child in slot_container.get_children():
		child.queue_free()
	slot_buttons.clear()

	# Create 4 slots: Autosave (0) + Slots 1-3
	for i in range(4):
		var button = create_slot_button(i)
		slot_container.add_child(button)
		slot_buttons.append(button)

func create_slot_button(slot_index: int) -> Button:
	var button = Button.new()
	button.custom_minimum_size = Vector2(600, 80)
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT

	# Set button style
	button.add_theme_font_size_override("font_size", 20)

	button.pressed.connect(func(): _on_slot_pressed(slot_index))

	return button

func refresh_slots():
	for i in range(4):
		update_slot_button(i)

func update_slot_button(slot_index: int):
	if slot_index >= slot_buttons.size():
		return

	var button = slot_buttons[slot_index]
	var has_save = SaveManager.has_save_in_slot(slot_index)

	# Slot name
	var slot_name = ""
	if slot_index == 0:
		slot_name = "Autosave"
	else:
		slot_name = "Slot " + str(slot_index)

	if has_save:
		# Get save info
		var info = SaveManager.get_slot_info(slot_index)
		var date_time = get_save_datetime(slot_index)

		button.text = slot_name + "\n" + date_time
		button.disabled = false

		# In LOAD mode, all filled slots are clickable
		# In SAVE mode, all slots are clickable (to overwrite)
	else:
		# Empty slot
		if mode == MenuMode.LOAD:
			button.text = slot_name + "\n[Empty]"
			button.disabled = true  # Can't load from empty slot
		else:
			button.text = slot_name + "\n[Empty - Click to Save]"
			button.disabled = false  # Can save to empty slot

func get_save_datetime(slot_index: int) -> String:
	# Get file modification time
	var slot_name = ""
	match slot_index:
		0: slot_name = "autosave"
		1: slot_name = "slot_1"
		2: slot_name = "slot_2"
		3: slot_name = "slot_3"

	var save_dir = "user://dialogic/saves/" + slot_name + "/"
	var file_path = save_dir + "state.txt"

	if not FileAccess.file_exists(file_path):
		return "[No data]"

	var file_time = FileAccess.get_modified_time(file_path)
	var datetime = Time.get_datetime_dict_from_unix_time(file_time)

	return "%02d/%02d/%04d %02d:%02d" % [
		datetime.month,
		datetime.day,
		datetime.year,
		datetime.hour,
		datetime.minute
	]

func _on_slot_pressed(slot_index: int):
	if mode == MenuMode.SAVE:
		# Saving mode
		if slot_index == 0:
			# Can't manually save to autosave slot
			push_warning("Cannot save to Autosave slot manually!")
			print("[SaveLoadMenu] ✗ Cannot manually save to autosave slot!")
			return

		# Save to slot
		var success = SaveManager.save_to_slot(slot_index)
		if success:
			print("[SaveLoadMenu] ✓ Player saved to slot " + str(slot_index))
			refresh_slots()
	else:
		# Loading mode — don't call Dialogic.Save.load() here.
		# Calling it before the VN scene loads causes a null instance crash
		# because the Dialogic layout nodes don't exist yet on the title screen.
		# Instead, store the slot name and let visual_novel.gd load it after setup.
		var slot_names = [SaveManager.AUTOSAVE, SaveManager.SLOT_1, SaveManager.SLOT_2, SaveManager.SLOT_3]
		if slot_index >= slot_names.size():
			print("[SaveLoadMenu] ✗ Invalid slot index")
			return
		var slot_name = slot_names[slot_index]
		if not Dialogic.Save.has_slot(slot_name):
			print("[SaveLoadMenu] ✗ Slot " + str(slot_index) + " is empty!")
			return
		print("[SaveLoadMenu] ✓ Queuing load from slot: " + slot_name)
		SaveManager.pending_load_slot = slot_name
		var tree = get_tree()
		_close_menu()
		tree.change_scene_to_file("res://scenes/visual_novel.tscn")

func _on_back_pressed():
	_close_menu()

## Close the menu, unpause Dialogic, and clean up the CanvasLayer parent (if any)
func _close_menu():
	Dialogic.paused = false
	if get_parent() is CanvasLayer:
		get_parent().queue_free()  # Frees the canvas layer and this node with it
	else:
		queue_free()

## Show the menu in LOAD mode
static func show_load_menu(parent: Node):
	var menu = load("res://scenes/save_load_menu.tscn").instantiate()
	menu.mode = MenuMode.LOAD
	parent.add_child(menu)

## Show the menu in SAVE mode
static func show_save_menu(parent: Node):
	var menu = load("res://scenes/save_load_menu.tscn").instantiate()
	menu.mode = MenuMode.SAVE
	parent.add_child(menu)
