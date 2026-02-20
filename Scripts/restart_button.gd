extends Button

func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	# Vérifier que get_tree() existe
	if get_tree():
		get_tree().reload_current_scene()
