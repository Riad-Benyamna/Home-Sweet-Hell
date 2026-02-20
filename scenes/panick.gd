extends DialogicBackground

@export var fade_duration: float = 0.5  
@export var hold_duration: float = 0.5 
@export var shake_strength: float = 3.0  
@export var shake_interval: float = 0.05  
@export var final_scale = Vector2(2,2)
@export var zoom_time : float = 20

@onready var sprite_a = $Sprite1
@onready var sprite_b = $Sprite2

@onready var rand = RandomNumberGenerator.new()

var original_position_a: Vector2
var original_position_b: Vector2
var shake_timer: float = 0.0

func _ready():
	Dialogic.signal_event.connect(_on_dialogic_signal)
	
	
	rand.randomize()
	original_position_a = sprite_a.position
	original_position_b = sprite_b.position
	
	
	sprite_a.modulate.a = 1.0
	sprite_b.modulate.a = 0.0
	
	
	start_loop()

func _process(delta: float):
	
	shake_timer += delta
	
	if shake_timer >= shake_interval:
		shake_timer = 0.0
		
		var shake_offset = Vector2(
			rand.randf_range(-shake_strength, shake_strength),
			rand.randf_range(-shake_strength, shake_strength)
		)
		
		sprite_a.position = original_position_a + shake_offset
		sprite_b.position = original_position_b + shake_offset



func zoom():
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(sprite_a, "scale", final_scale, zoom_time).set_ease(Tween.EASE_OUT)
	tween.tween_property(sprite_b, "scale", final_scale, zoom_time).set_ease(Tween.EASE_OUT)
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

func _on_dialogic_signal(argument: String):
	if argument == "panick":
		zoom()
