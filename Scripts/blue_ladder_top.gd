extends Area2D

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.name == "Seb":
		body.ladder_count += 1
		body.velocity.y = 0

func _on_body_exited(body):
	if body.name == "Seb":
		body.ladder_count -= 1
		body.ladder_count = max(body.ladder_count, 0)
