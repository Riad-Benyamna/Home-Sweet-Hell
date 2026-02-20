extends Camera2D
@export var randomStrength : float = 30.0
var random = RandomNumberGenerator.new()
var shake_strength : float = 10
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	apply_shake()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func apply_shake():
	shake_strength= randomStrength

func randomOffeset() -> Vector2:
	return Vector2(random.randf_range(-shake_strength,shake_strength),random.randf_range(-shake_strength,shake_strength))
