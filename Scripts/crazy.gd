extends DialogicBackground

@export var fade_duration: float = 1.0  
@export var hold_duration: float = 2.0  

@onready var sprite_a = $Sprite1
@onready var sprite_b = $Sprite2

func _ready():
	
	sprite_a.modulate.a = 1.0
	sprite_b.modulate.a = 0.0
	
	
	start_loop()

func start_loop():
	while true:
		
		await fade_in(sprite_b)
		
		
		await get_tree().create_timer(hold_duration).timeout
		
		
		await fade_out(sprite_b)
		
		
		await get_tree().create_timer(hold_duration).timeout

func fade_in(sprite: Sprite2D):
	var tween = create_tween()
	tween.tween_property(sprite, "modulate:a", 1.0, fade_duration)
	await tween.finished

func fade_out(sprite: Sprite2D):
	var tween = create_tween()
	tween.tween_property(sprite, "modulate:a", 0.0, fade_duration)
	await tween.finished
