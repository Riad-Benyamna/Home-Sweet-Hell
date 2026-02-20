extends Node

@export var blue_button: AnimatableBody2D
@export var blue_ladder_container: Node2D  # ← Le conteneur avec tous les morceaux
@export var blue_platform: StaticBody2D
@export var ladder_fade_time := 0.6

var button_pressed: bool = false

func _ready():
	if blue_button:
		blue_button.button_activated.connect(_on_blue_button_activated)
		print("Blue button connected!")
	
	# S'assurer que l'échelle est cachée au départ
	if blue_ladder_container:
		hide_ladder()

func _on_blue_button_activated():
	if button_pressed:
		return
	
	button_pressed = true
	print("Activating blue button effects...")
	
	# Faire apparaître tous les morceaux d'échelle
	show_ladder()
	
	# Faire disparaître la plateforme
	remove_platform()

func show_ladder():
	if not blue_ladder_container:
		print("ERROR: Blue ladder container not found!")
		return
	
	blue_ladder_container.visible = true
	blue_ladder_container.process_mode = Node.PROCESS_MODE_INHERIT
	blue_ladder_container.modulate.a = 0.0
	
	# Désactiver collisions pendant le fondu
	for child in blue_ladder_container.get_children():
		if child is Area2D:
			child.monitoring = false
			child.monitorable = false
			child.process_mode = Node.PROCESS_MODE_INHERIT
	
	# Tween de fondu
	var tween := create_tween()
	tween.tween_property(
		blue_ladder_container,
		"modulate:a",
		1.0,
		ladder_fade_time
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	# Réactiver collisions à la fin
	tween.finished.connect(func():
		for child in blue_ladder_container.get_children():
			if child is Area2D:
				child.monitoring = true
				child.monitorable = true
		print("Blue ladder shown with fade! (", blue_ladder_container.get_child_count(), " pieces)")
	)

func hide_ladder():
	if blue_ladder_container:
		blue_ladder_container.visible = false
		blue_ladder_container.process_mode = Node.PROCESS_MODE_DISABLED
		
		# Désactiver tous les morceaux enfants
		for child in blue_ladder_container.get_children():
			if child is Area2D:
				child.process_mode = Node.PROCESS_MODE_DISABLED
				child.monitoring = false
				child.monitorable = false
		
		print("Blue ladder hidden")

func remove_platform():
	if blue_platform:
		blue_platform.queue_free()
		print("Blue platform removed!")
	else:
		print("ERROR: Blue platform not assigned!")
