extends Control

func _ready() -> void:
	# Connecter le bouton
	$Button.pressed.connect(_on_button_pressed)

func _on_button_pressed() -> void:
	get_tree().call_deferred("reload_current_scene")
