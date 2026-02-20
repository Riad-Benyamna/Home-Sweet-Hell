extends Node

@export var yellow_button: AnimatableBody2D
@export var spring_container: Node2D
@export var yellow_platform_container: Node2D
@export var Hint: Node2D


var button_pressed: bool = false

func _ready():
	if yellow_button:
		yellow_button.button_activated.connect(_on_yellow_button_activated)
		print("yellow button connected!")
	
	if yellow_platform_container:
		hide_platforms()
		hide_spring_container()

func _on_yellow_button_activated():
	if button_pressed:
		return
	
	button_pressed = true
	print("Activating yellow button effects...")
	
	# Faire apparaître tous les morceaux d'échelle
	show_platforms()
	show_spring_container()
	Hint.queue_free()

func show_platforms():
	if not yellow_platform_container:
		return
	
	yellow_platform_container.visible = true
	yellow_platform_container.process_mode = Node.PROCESS_MODE_INHERIT
	
	for child in yellow_platform_container.get_children():
		if child is AnimatableBody2D:
			child.visible = true
			child.process_mode = Node.PROCESS_MODE_INHERIT
			
			var col := child.get_node_or_null("CollisionShape2D")
			if col:
				# Méthode recommandée : forcer la ré-évaluation de la collision
				col.disabled = true
				await get_tree().process_frame
				col.disabled = false
				
				# Option supplémentaire très efficace dans beaucoup de cas
				child.call_deferred("set_collision_layer", child.collision_layer)
	
	print("Yellow platforms shown!")

func hide_platforms():
	if not yellow_platform_container:
		return
	
	yellow_platform_container.visible = false
	yellow_platform_container.process_mode = Node.PROCESS_MODE_DISABLED
	
	for child in yellow_platform_container.get_children():
		if child is AnimatableBody2D:
			child.visible = false
			child.process_mode = Node.PROCESS_MODE_DISABLED
			
			var col := child.get_node_or_null("CollisionShape2D")
			if col:
				col.disabled = true
	
	print("Yellow platforms hidden!")
	
func show_spring_container():
	if not spring_container:
		return
	spring_container.visible = true
	spring_container.process_mode = Node.PROCESS_MODE_INHERIT
	
	for child in spring_container.get_children():
		if child is AnimatableBody2D:
			child.visible = true
			child.process_mode = Node.PROCESS_MODE_INHERIT
			
			var col := child.get_node_or_null("CollisionShape2D")
			if col:
				# Méthode recommandée : forcer la ré-évaluation de la collision
				col.disabled = true
				await get_tree().process_frame
				col.disabled = false
				
				# Option supplémentaire très efficace dans beaucoup de cas
				child.call_deferred("set_collision_layer", child.collision_layer)
				
func hide_spring_container():
	if not spring_container:
		return
	spring_container.visible = false
	spring_container.process_mode = Node.PROCESS_MODE_DISABLED
	
	for child in spring_container.get_children():
		if child is AnimatableBody2D:
			child.visible = false
			child.process_mode = Node.PROCESS_MODE_DISABLED
			
			var col := child.get_node_or_null("CollisionShape2D")
			if col:
				col.disabled = true
