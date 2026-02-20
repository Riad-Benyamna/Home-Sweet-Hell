extends CanvasLayer

@onready var rect := get_node("FadeRect")

func fade_out(duration := 0.5) -> void:
	rect.visible = true
	rect.modulate.a = 0.0

	var tween = create_tween()
	tween.tween_property(rect, "modulate:a", 1.0, duration)
	await tween.finished

	# IMPORTANT : attendre une frame de rendu
	await get_tree().process_frame

func fade_in(duration := 0.5) -> void:
	rect.modulate.a = 1.0
	rect.visible = true

	var tween = create_tween()
	tween.tween_property(rect, "modulate:a", 0.0, duration)
	await tween.finished

	rect.visible = false
