extends CanvasLayer

@export var heart_full_texture: Texture2D
@export var heart_empty_texture: Texture2D

@onready var heart_container = $HeartContainer

var hearts: Array = []
var previous_health: int = 5

func _ready():
	GameManager.health_changed.connect(_on_health_changed)
	create_hearts(GameManager.max_health)
	previous_health = GameManager.get_health()
	update_hearts(GameManager.get_health())

func create_hearts(amount: int):
	for heart in hearts:
		heart.queue_free()
	hearts.clear()
	
	for i in range(amount):
		var heart = TextureRect.new()
		heart.texture = heart_full_texture
		heart.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		heart.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		heart.custom_minimum_size = Vector2(64, 64)
		
		heart_container.add_child(heart)
		hearts.append(heart)

func _on_health_changed(new_health: int):
	update_hearts(new_health)

func update_hearts(current_health: int):
	# Déterminer quel cœur animer
	if current_health < previous_health:
		# L'index du cœur à animer est égal à la nouvelle santé
		var heart_to_animate_index = current_health
		
		if heart_to_animate_index >= 0 and heart_to_animate_index < hearts.size():
			animate_heart_death(hearts[heart_to_animate_index])
	
	
	# On attend un frame pour que l'animation ait le temps de démarrer
	await get_tree().process_frame
	
	for i in range(hearts.size()):
		if i < current_health:
			# Cœur plein - ne rien toucher s'il est déjà plein
			if hearts[i].texture != heart_full_texture:
				hearts[i].texture = heart_full_texture
				hearts[i].modulate = Color.WHITE
				hearts[i].scale = Vector2.ONE
		# Les cœurs vides sont gérés par l'animation elle-même
	
	previous_health = current_health

func animate_heart_death(heart: TextureRect):
	var tween = create_tween()
	
	# Battement rapide (panique)
	tween.tween_property(heart, "scale", Vector2(1.3, 1.3), 0.08)
	tween.tween_property(heart, "scale", Vector2.ONE, 0.08)
	tween.tween_property(heart, "scale", Vector2(1.3, 1.3), 0.08)
	tween.tween_property(heart, "scale", Vector2.ONE, 0.08)
	tween.tween_property(heart, "scale", Vector2(1.2, 1.2), 0.08)
	tween.tween_property(heart, "scale", Vector2.ONE, 0.08)
	
	# Pause
	tween.tween_interval(0.1)
	
	# Dernier battement faible
	tween.tween_property(heart, "scale", Vector2(1.1, 1.1), 0.15)
	tween.tween_property(heart, "scale", Vector2.ONE, 0.15)
	
	# Mort : change de texture et rétrécit
	tween.tween_callback(func(): 
		heart.texture = heart_empty_texture
	)
	tween.set_parallel(true)
	tween.tween_property(heart, "scale", Vector2(0.7, 0.7), 0.3)
	tween.tween_property(heart, "modulate:a", 0.3, 0.3)
