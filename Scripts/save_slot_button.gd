extends Button

## Individual save slot button
## Shows slot info and handles click

signal slot_selected(slot_index: int)

var slot_index: int = 0
var is_save_mode: bool = false

func setup(index: int, save_mode: bool):
	slot_index = index
	is_save_mode = save_mode
	refresh_display()

func refresh_display():
	var has_save = SaveManager.has_save_in_slot(slot_index)

	# Slot name
	var slot_name = ""
	if slot_index == 0:
		slot_name = "Autosave"
	else:
		slot_name = "Slot " + str(slot_index)

	if has_save:
		var date_time = get_save_datetime()
		text = slot_name + "\n" + date_time
		disabled = false
	else:
		if is_save_mode:
			if slot_index == 0:
				text = slot_name + "\n[Autosave Only]"
				disabled = true  # Can't manually save to autosave
			else:
				text = slot_name + "\n[Empty - Click to Save]"
				disabled = false
		else:
			text = slot_name + "\n[Empty]"
			disabled = true

func get_save_datetime() -> String:
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

func _pressed():
	slot_selected.emit(slot_index)
