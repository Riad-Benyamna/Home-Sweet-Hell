@tool
extends DialogicLayoutLayer

## Layer that provides a popup with glossary info,
## when hovering a glossary entry on a text node.

@export_group("Text")
enum Alignment { LEFT, CENTER, RIGHT }
@export var title_alignment: Alignment = Alignment.LEFT
@export var text_alignment: Alignment = Alignment.LEFT
@export var extra_alignment: Alignment = Alignment.RIGHT

@export_subgroup("Colors")
enum TextColorModes { GLOBAL, ENTRY, CUSTOM }
@export var title_color_mode: TextColorModes = TextColorModes.ENTRY
@export var title_custom_color: Color = Color.WHITE
@export var text_color_mode: TextColorModes = TextColorModes.ENTRY
@export var text_custom_color: Color = Color.WHITE
@export var extra_color_mode: TextColorModes = TextColorModes.ENTRY
@export var extra_custom_color: Color = Color.WHITE

@export_group("Font")
@export var font_use_global: bool = true
@export_file("*.ttf", "*.tres") var font_custom: String = ""

@export_subgroup("Sizes")
@export var font_title_size: int = 18
@export var font_text_size: int = 17
@export var font_extra_size: int = 15

@export_group("Box")
@export_subgroup("Color")
enum ModulateModes { BASE_COLOR_ONLY, ENTRY_COLOR_ON_BOX, GLOBAL_BG_COLOR }
@export var box_modulate_mode: ModulateModes = ModulateModes.ENTRY_COLOR_ON_BOX
@export var box_base_modulate: Color = Color.WHITE

@export_subgroup("Size")
@export var box_width: int = 200

const MISSING_INDEX := -1

func get_pointer() -> Control:
	return $Pointer

func get_title() -> Label:
	return %Title

func get_text() -> RichTextLabel:
	return %Text

func get_extra() -> RichTextLabel:
	return %Extra

func get_panel() -> PanelContainer:
	return %Panel

func get_panel_point() -> PanelContainer:
	return %PanelPoint


func _ready() -> void:
	if Engine.is_editor_hint():
		return

	var dialogic := DialogicUtil.autoload()
	if dialogic == null or not dialogic.has_node("Text"):
		return

	get_pointer().hide()

	var text_system: Node = dialogic.get("Text")

	# Godot 4 safe signal connections
	if text_system.has_signal("animation_textbox_hide"):
		text_system.animation_textbox_hide.connect(get_pointer().hide)

	if text_system.has_signal("meta_hover_started"):
		text_system.meta_hover_started.connect(_on_dialogic_display_dialog_text_meta_hover_started)

	if text_system.has_signal("meta_hover_ended"):
		text_system.meta_hover_ended.connect(_on_dialogic_display_dialog_text_meta_hover_ended)


## Show popup
func _on_dialogic_display_dialog_text_meta_hover_started(meta: String) -> void:
	var dialogic := DialogicUtil.autoload()
	if dialogic == null:
		return

	var entry_info := dialogic.Glossary.get_entry(meta)
	if entry_info.is_empty():
		return

	get_pointer().show()

	get_title().text = entry_info.title
	get_text().text = ["", "[center]", "[right]"][text_alignment] + entry_info.text
	get_extra().text = ["", "[center]", "[right]"][extra_alignment] + entry_info.extra

	get_pointer().global_position = get_pointer().get_global_mouse_position()

	if title_color_mode == TextColorModes.ENTRY:
		get_title().add_theme_color_override("font_color", entry_info.color)
	if text_color_mode == TextColorModes.ENTRY:
		get_text().add_theme_color_override("default_color", entry_info.color)
	if extra_color_mode == TextColorModes.ENTRY:
		get_extra().add_theme_color_override("default_color", entry_info.color)

	match box_modulate_mode:
		ModulateModes.ENTRY_COLOR_ON_BOX:
			get_panel().self_modulate = entry_info.color
			get_panel_point().self_modulate = entry_info.color


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return

	var pointer := get_pointer()
	if pointer.visible:
		pointer.global_position = pointer.get_global_mouse_position()


func _on_dialogic_display_dialog_text_meta_hover_ended(_meta: String) -> void:
	get_pointer().hide()


func _apply_export_overrides() -> void:
	# ---------- Fonts ----------
	var font: Font = null

	var global_font_setting := get_global_setting("font", "")
	if typeof(global_font_setting) != TYPE_STRING:
		global_font_setting = ""

	if font_use_global and global_font_setting != "" and ResourceLoader.exists(global_font_setting):
		font = load(global_font_setting)
	elif font_custom != "" and ResourceLoader.exists(font_custom):
		font = load(font_custom)

	var title := get_title()
	if font:
		title.add_theme_font_override("font", font)

	title.horizontal_alignment = title_alignment as HorizontalAlignment
	title.add_theme_font_size_override("font_size", font_title_size)

	var labels: Array[RichTextLabel] = [get_text(), get_extra()]
	var sizes := [font_text_size, font_extra_size]

	for i in labels.size():
		if font:
			labels[i].add_theme_font_override("normal_font", font)

		labels[i].add_theme_font_size_override("normal_font_size", sizes[i])
		labels[i].add_theme_font_size_override("bold_font_size", sizes[i])
		labels[i].add_theme_font_size_override("italics_font_size", sizes[i])
		labels[i].add_theme_font_size_override("bold_italics_font_size", sizes[i])
		labels[i].add_theme_font_size_override("mono_font_size", sizes[i])

	# ---------- Text colors ----------
	var controls: Array[Control] = [get_title(), get_text(), get_extra()]
	var settings := ["font_color", "default_color", "default_color"]
	var color_modes := [title_color_mode, text_color_mode, extra_color_mode]
	var custom_colors := [title_custom_color, text_custom_color, extra_custom_color]

	for i in controls.size():
		match color_modes[i]:
			TextColorModes.GLOBAL:
				var col := get_global_setting("font_color", custom_colors[i])
				if col is Color:
					controls[i].add_theme_color_override(settings[i], col)
			TextColorModes.CUSTOM:
				controls[i].add_theme_color_override(settings[i], custom_colors[i])

	# ---------- Box ----------
	var panel := get_panel()
	panel.size.x = box_width
	panel.position.x = -box_width / 2.0

	match box_modulate_mode:
		ModulateModes.BASE_COLOR_ONLY:
			panel.self_modulate = box_base_modulate
			get_panel_point().self_modulate = box_base_modulate

		ModulateModes.GLOBAL_BG_COLOR:
			var bg := get_global_setting("bg_color", box_base_modulate)
			if bg is Color:
				panel.self_modulate = bg
				get_panel_point().self_modulate = bg
