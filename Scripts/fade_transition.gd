extends Node

var color_rect: ColorRect
var next_scene: String

func start_transition():
	# Changer de scène
	get_tree().change_scene_to_file(next_scene)
	
	# Attendre que la nouvelle scène soit chargée
	await get_tree().create_timer(0.1).timeout
	
	# FADE IN : Le blanc disparaît progressivement
	var fade_in_tween = get_tree().create_tween()
	fade_in_tween.tween_property(color_rect, "modulate:a", 0.0, 1.5)
	await fade_in_tween.finished
	
	# Nettoyer la transition
	queue_free()
