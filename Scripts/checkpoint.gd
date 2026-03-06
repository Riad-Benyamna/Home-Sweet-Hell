extends Area2D

@export var checkpoint_id: int = 0

@onready var sprite: Sprite2D = $Sprite2D

var activated: bool = false

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D):
	if activated:
		return
	if body.name != "Seb":
		return

	activated = true
	GameManager.save_checkpoint(body.global_position)
	_flash_sprite()

func _flash_sprite():
	for i in 3:
		sprite.modulate = Color(1.5, 1.5, 0.5)
		await get_tree().create_timer(0.1).timeout
		sprite.modulate = Color(1, 1, 1)
		await get_tree().create_timer(0.1).timeout
