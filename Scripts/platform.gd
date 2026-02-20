extends AnimatableBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	HandleAnimations()
	var tween = create_tween().set_loops()
	tween.tween_property(self, "position:y", position.y - 60, 1)
	tween.tween_property(self, "position:y", position.y, 1)

func HandleAnimations():
	$cloud.play("idle")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
