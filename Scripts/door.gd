extends AnimatableBody2D

@export var coins_required: int = 160
@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D
@onready var label = $Label
@onready var detection_area = $Area2D  # zone pour détecter Seb

var is_open: bool = false
var player_nearby := false

func _ready():
	# Vérifier l'état initial de la porte
	update_door_state()
	
	# Connexion au signal de coins
	GameManager.coins_changed.connect(_on_coins_changed)
	
	# Connexion aux entrées/sorties de Seb
	detection_area.body_entered.connect(_on_player_entered)
	detection_area.body_exited.connect(_on_player_exited)

func _on_coins_changed(new_amount: int):
	update_door_state()

func _on_player_entered(body):
	if body.name == "Seb":
		player_nearby = true
		update_door_state()

func _on_player_exited(body):
	if body.name == "Seb":
		player_nearby = false
		update_door_state()

func update_door_state():
	var current_coins = GameManager.get_coins()
	var can_open = current_coins >= coins_required and player_nearby

	if can_open and not is_open:
		open_door()
	
	# Mettre à jour le label si la porte n'est pas ouverte
	if not is_open:
		var remaining = coins_required - current_coins
		if remaining > 0:
			label.text = "Pathetic, without " + str(remaining) + " more coins, you shalt not pass"
		else:
			if player_nearby:
				label.text = "Press E to open the door"
			else:
				label.text = "Ugh...So be it"

func open_door():
	is_open = true
	print("Door opened!")

	# Désactiver la collision
	collision.set_deferred("disabled", true)
	
	# Animation de disparition progressive
	var tween = create_tween()
	tween.tween_property(sprite, "modulate:a", 0.0, 0.5)
	
	# Masquer le label
	label.visible = false
