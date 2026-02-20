@tool
extends DialogicLayoutLayer

## Example scene for viewing the History
## Implements most of the visual options from 1.x History mode

# -------------------------------------------------------------------
# EXPORTS
# -------------------------------------------------------------------

@export_group("Look")
@export_subgroup("Font")
@export var font_use_global_size: bool = true
@export var font_custom_size: int = 15
@export var font_use_global_fonts: bool = true
@export_file("*.ttf", "*.tres") var font_custom_normal: String = ""
@export_file("*.ttf", "*.tres") var font_custom_bold: String = ""
@export_file("*.ttf", "*.tres") var font_custom_italics: String = ""

@export_subgroup("Buttons")
@export var show_open_button: bool = true
@export var show_close_button: bool = true

@export_group("Settings")
@export_subgroup("Events")
@export var show_all_choices: bool = true
@export var show_join_and_leave: bool = true

@export_subgroup("Behaviour")
@export var scroll_to_bottom: bool = true
@export var show_name_colors: bool = true
@export var name_delimeter: String = ": "

@export_group("Private")
@export var HistoryItem: PackedScene = null

# -------------------------------------------------------------------
# INTERNAL
# -------------------------------------------------------------------

var scroll_to_bottom_flag: bool = false
var history_item_theme: Theme = null

# -------------------------------------------------------------------
# NODE GETTERS
# -------------------------------------------------------------------

func get_show_history_button() -> Button:
	return $ShowHistory

func get_hide_history_button() -> Button:
	return $HideHistory

func get_history_box() -> ScrollContainer:
	return %HistoryBox

func get_history_log() -> VBoxContainer:
	return %HistoryLog

# -------------------------------------------------------------------
# READY
# -------------------------------------------------------------------

func _ready() -> void:
	if Engine.is_editor_hint():
		return

	var dialogic := DialogicUtil.autoload()
	if dialogic == null or not dialogic.has_node("History"):
		return

	dialogic.History.open_requested.connect(_on_show_history_pressed)
	dialogic.History.close_requested.connect(_on_hide_history_pressed)

# -------------------------------------------------------------------
# APPLY EXPORT OVERRIDES
# -------------------------------------------------------------------

func _apply_export_overrides() -> void:
	var dialogic := DialogicUtil.autoload()
	if dialogic == null:
		set("visible", false)
		return

	var history_subsystem := dialogic.get("History")
	if history_subsystem != null:
		get_show_history_button().visible = show_open_button and history_subsystem.get("simple_history_enabled")
	else:
		set("visible", false)
		return

	history_item_theme = Theme.new()

	# ---------- FONT SIZE ----------
	if font_use_global_size:
		var size_val = get_global_setting("font_size", font_custom_size)
		if size_val is int:
			history_item_theme.default_font_size = size_val
		else:
			history_item_theme.default_font_size = font_custom_size
	else:
		history_item_theme.default_font_size = font_custom_size

	# ---------- FONT FAMILY ----------
	var global_font_setting = get_global_setting("font", null)
	var resolved_font_path := ""

	if font_use_global_fonts:
		if global_font_setting is String:
			resolved_font_path = global_font_setting
		elif global_font_setting is StringName:
			resolved_font_path = String(global_font_setting)

	if resolved_font_path != "" and ResourceLoader.exists(resolved_font_path):
		history_item_theme.default_font = load(resolved_font_path)
	elif font_custom_normal != "" and ResourceLoader.exists(font_custom_normal):
		history_item_theme.default_font = load(font_custom_normal)

	# ---------- BOLD / ITALICS ----------
	if font_custom_bold != "" and ResourceLoader.exists(font_custom_bold):
		history_item_theme.set_font("RichTextLabel", "bold_font", load(font_custom_bold))

	if font_custom_italics != "" and ResourceLoader.exists(font_custom_italics):
		history_item_theme.set_font("RichTextLabel", "italics_font", load(font_custom_italics))

# -------------------------------------------------------------------
# PROCESS
# -------------------------------------------------------------------

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return

	if scroll_to_bottom_flag and get_history_box().visible and get_history_log().get_child_count() > 0:
		await get_tree().process_frame
		get_history_box().ensure_control_visible(get_history_log().get_children()[-1] as Control)
		scroll_to_bottom_flag = false

# -------------------------------------------------------------------
# SHOW / HIDE
# -------------------------------------------------------------------

func _on_show_history_pressed() -> void:
	DialogicUtil.autoload().paused = true
	show_history()

func show_history() -> void:
	for child in get_history_log().get_children():
		child.queue_free()

	var history_subsystem := DialogicUtil.autoload().get("History")
	if history_subsystem == null:
		return

	for info: Dictionary in history_subsystem.call("get_simple_history"):
		var history_item := HistoryItem.instantiate()
		history_item.set("theme", history_item_theme)

		match info.event_type:
			"Text":
				if info.has("character") and info["character"]:
					if show_name_colors:
						history_item.call("load_info", info["text"], info["character"] + name_delimeter, info["character_color"])
					else:
						history_item.call("load_info", info["text"], info["character"] + name_delimeter)
				else:
					history_item.call("load_info", info["text"])

			"Character":
				if not show_join_and_leave:
					history_item.queue_free()
					continue
				history_item.call("load_info", "[i]" + info["text"])

			"Choice":
				var choices_text := ""
				if show_all_choices:
					for choice in info["all_choices"]:
						if choice.ends_with("#disabled"):
							choices_text += "-  [i](" + choice.trim_suffix("#disabled") + ")[/i]\n"
						elif choice == info["text"]:
							choices_text += "-> [b]" + choice + "[/b]\n"
						else:
							choices_text += "-> " + choice + "\n"
				else:
					choices_text += "- [b]" + info["text"] + "[/b]\n"

				history_item.call("load_info", choices_text)

		get_history_log().add_child(history_item)

	if scroll_to_bottom:
		scroll_to_bottom_flag = true

	get_show_history_button().hide()
	get_hide_history_button().visible = show_close_button
	get_history_box().show()

func _on_hide_history_pressed() -> void:
	DialogicUtil.autoload().paused = false
	get_history_box().hide()
	get_hide_history_button().hide()

	var history_subsystem := DialogicUtil.autoload().get("History")
	if history_subsystem != null:
		get_show_history_button().visible = show_open_button and history_subsystem.get("simple_history_enabled")
