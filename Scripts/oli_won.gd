extends DialogicBackground

@export var fade_duration: float = 0.5  # Durée du fondu
@export var hold_duration: float = 1.0  # Durée où sprite2 reste visible

@onready var sprite_a = $Sprite1
@onready var sprite_b = $Sprite2

func _ready():
	# Sprite1 toujours visible en arrière-plan
	sprite_a.modulate.a = 1.0
	sprite_b.modulate.a = 0.0
	
	# Lance la boucle
	start_loop()

func start_loop():
	while true:
		# Sprite2 apparaît en fondu
		await fade_in(sprite_b)
		
		# Sprite2 reste visible pendant hold_duration
		await get_tree().create_timer(hold_duration).timeout
		
		# Sprite2 disparaît en fondu
		await fade_out(sprite_b)
		
		# Pause avant de recommencer (optionnel)
		await get_tree().create_timer(hold_duration).timeout

func fade_in(sprite: Sprite2D):
	var tween = create_tween()
	tween.tween_property(sprite, "modulate:a", 1.0, fade_duration)
	await tween.finished

func fade_out(sprite: Sprite2D):
	var tween = create_tween()
	tween.tween_property(sprite, "modulate:a", 0.0, fade_duration)
	await tween.finished
