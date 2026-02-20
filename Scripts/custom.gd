extends DialogicPortrait

@export_group('Main')
@export_file var image := ""
var unhighlighted_color := Color.DARK_GRAY
var _prev_z_index := 0

## Load anything related to the given character and portrait
func _update_portrait(passed_character:DialogicCharacter, passed_portrait:String) -> void:
	apply_character_and_portrait(passed_character, passed_portrait)
	
	# Trouver le Sprite2D dans les enfants
	var sprite_node = null
	for child in get_children():
		if child is Sprite2D:
			sprite_node = child
			break
	
	if sprite_node and image:
		apply_texture(sprite_node, image)
		# S'assurer que le sprite est visible
		sprite_node.visible = true
		sprite_node.modulate.a = 1.0  # Alpha à 100%
		print("Sprite updated: ", sprite_node.name, " | Image: ", image)
	elif not sprite_node:
		print("ERROR: No Sprite2D child found!")
	elif not image:
		print("WARNING: No image path provided for character: ", passed_character.display_name if passed_character else "Unknown")

func _ready() -> void:
	if not Engine.is_editor_hint():
		self.modulate = Color.WHITE  # Par défaut, tous les personnages sont visibles

func _highlight() -> void:
	# Quand ce personnage parle, on le met en avant
	create_tween().tween_property(self, 'modulate', Color.WHITE, 0.15)
	_prev_z_index = DialogicUtil.autoload().Portraits.get_character_info(character).get('z_index', 0)
	DialogicUtil.autoload().Portraits.change_character_z_index(character, 99)

func _unhighlight() -> void:
	# Quand un AUTRE personnage parle, on grise celui-ci
	create_tween().tween_property(self, 'modulate', unhighlighted_color, 0.15)
	DialogicUtil.autoload().Portraits.change_character_z_index(character, _prev_z_index)
