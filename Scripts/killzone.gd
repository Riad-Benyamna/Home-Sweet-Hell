extends Area2D

@export var damage: int = 1  # Dégâts infligés
@export var instant_kill: bool = false  # True = tue directement

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Seb":
		if instant_kill:
			# Mort instantanée (pour les puits sans fond par exemple)
			for i in range(GameManager.max_health):
				GameManager.take_damage(1)
		else:
			# Dégâts normaux
			if body.has_method("take_damage"):
				body.take_damage(damage)
