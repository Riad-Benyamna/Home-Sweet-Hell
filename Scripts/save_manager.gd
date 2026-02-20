extends Node

## Global save manager for Nocturnal Tots
## Manages 3 manual save slots + 1 autosave slot
## Only allows saving during VN sections (not gameplay)

signal save_slots_updated

const SLOT_1 = "slot_1"
const SLOT_2 = "slot_2"
const SLOT_3 = "slot_3"
const AUTOSAVE = "autosave"

## Flag to control whether saving is allowed
## Set to false during gameplay sections (platformer/rhythm)
var saving_enabled: bool = true

func _ready():
	# Ensure Dialogic autosave is initially enabled
	Dialogic.Save.autosave_enabled = true

## Enable saving (call when entering VN sections)
func enable_saving():
	saving_enabled = true
	Dialogic.Save.autosave_enabled = true
	print("[SaveManager] Saving ENABLED (VN mode)")

## Disable saving (call when entering gameplay sections)
func disable_saving():
	saving_enabled = false
	Dialogic.Save.autosave_enabled = false
	print("[SaveManager] Saving DISABLED (Gameplay mode)")

## Manually save to a specific slot (1, 2, or 3)
func save_to_slot(slot_number: int) -> bool:
	if not saving_enabled:
		push_warning("[SaveManager] Cannot save during gameplay!")
		return false

	var slot_name = ""
	match slot_number:
		1: slot_name = SLOT_1
		2: slot_name = SLOT_2
		3: slot_name = SLOT_3
		_:
			push_error("[SaveManager] Invalid slot number: " + str(slot_number))
			return false

	var result = Dialogic.Save.save(slot_name, false, Dialogic.Save.ThumbnailMode.TAKE_AND_STORE)

	if result == OK:
		print("[SaveManager] Saved to slot " + str(slot_number))
		save_slots_updated.emit()
		return true
	else:
		push_error("[SaveManager] Failed to save to slot " + str(slot_number))
		return false

## Load from a specific slot
func load_from_slot(slot_number: int) -> bool:
	var slot_name = ""
	match slot_number:
		0: slot_name = AUTOSAVE  # 0 = autosave
		1: slot_name = SLOT_1
		2: slot_name = SLOT_2
		3: slot_name = SLOT_3
		_:
			push_error("[SaveManager] Invalid slot number: " + str(slot_number))
			return false

	if not Dialogic.Save.has_slot(slot_name):
		push_warning("[SaveManager] Slot " + str(slot_number) + " is empty!")
		return false

	var result = Dialogic.Save.load(slot_name)

	if result == OK:
		print("[SaveManager] Loaded from slot " + str(slot_number))
		return true
	else:
		push_error("[SaveManager] Failed to load from slot " + str(slot_number))
		return false

## Check if a slot has save data
func has_save_in_slot(slot_number: int) -> bool:
	var slot_name = ""
	match slot_number:
		0: slot_name = AUTOSAVE
		1: slot_name = SLOT_1
		2: slot_name = SLOT_2
		3: slot_name = SLOT_3
		_: return false

	return Dialogic.Save.has_slot(slot_name)

## Get slot info (for displaying in UI)
func get_slot_info(slot_number: int) -> Dictionary:
	var slot_name = ""
	match slot_number:
		0: slot_name = AUTOSAVE
		1: slot_name = SLOT_1
		2: slot_name = SLOT_2
		3: slot_name = SLOT_3
		_: return {}

	if not Dialogic.Save.has_slot(slot_name):
		return {}

	return Dialogic.Save.get_slot_info(slot_name)

## Delete a save slot
func delete_slot(slot_number: int) -> bool:
	var slot_name = ""
	match slot_number:
		0: slot_name = AUTOSAVE
		1: slot_name = SLOT_1
		2: slot_name = SLOT_2
		3: slot_name = SLOT_3
		_: return false

	if Dialogic.Save.has_slot(slot_name):
		Dialogic.Save.delete_slot(slot_name)
		save_slots_updated.emit()
		return true

	return false

## Check if ANY save exists (for showing/hiding Continue button)
func has_any_save() -> bool:
	return has_save_in_slot(0) or has_save_in_slot(1) or has_save_in_slot(2) or has_save_in_slot(3)
