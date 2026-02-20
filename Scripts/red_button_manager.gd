extends Node

@export var red_button: AnimatableBody2D # ← Le conteneur avec tous les morceaux
@export var red_wall: Node2D

var button_pressed: bool = false

func _ready():
	if red_button:
		red_button.button_activated.connect(_on_red_button_activated)
		print("Blue button connected!")
	
	# S'assurer que l'échelle est cachée au départ


func _on_red_button_activated():
	if button_pressed:
		return
	
	button_pressed = true
	print("Activating red button effects...")
	
	# Faire apparaître tous les morceaux d'échelle
	
	
	# Faire disparaître la plateforme
	remove_wall()

func remove_wall():
	for child in red_wall.get_children():
		if child is AnimatableBody2D:
			red_wall.queue_free()
			print("Red wall removed!")
