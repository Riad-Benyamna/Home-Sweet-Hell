extends Node2D

@onready var bubble: Sprite2D = $TokenBubble
@onready var detection_area: Area2D = $Area2D

var bubble_visible := false
var bubble_tween: Tween

func _ready() -> void:
	bubble.visible = true
	bubble.modulate.a = 0.0
	
	detection_area.body_entered.connect(_on_player_entered)
	detection_area.body_exited.connect(_on_player_exited)

func _on_player_entered(body):
	if body.name == "Seb":
		show_bubble()

func _on_player_exited(body):
	if body.name == "Seb":
		hide_bubble()

func show_bubble():
	if bubble_visible:
		return
	
	bubble_visible = true
	
	if bubble_tween:
		bubble_tween.kill()
	
	bubble_tween = create_tween()
	bubble_tween.tween_property(
		bubble,
		"modulate:a",
		1.0,
		0.25
	).set_ease(Tween.EASE_OUT)

func hide_bubble():
	if not bubble_visible:
		return
	
	bubble_visible = false
	
	if bubble_tween:
		bubble_tween.kill()
	
	bubble_tween = create_tween()
	bubble_tween.tween_property(
		bubble,
		"modulate:a",
		0.0,
		0.25
	).set_ease(Tween.EASE_IN)
