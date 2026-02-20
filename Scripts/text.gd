extends RichTextLabel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	show_text()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func show_text():
	var tween := create_tween()
	tween.tween_property(RichTextLabel, "modulate:a", 1, 1)
