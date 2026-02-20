extends AnimatableBody2D

@export var crack_delay := 1  # Temps avant de commencer à tomber
@export var fall_speed := 500.0  # Vitesse de chute
@export var respawn_time := 3.0  # Temps avant réapparition
@export var shake_intensity := 12.0  # Intensité du tremblement

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var detection_area: Area2D = $DetectionArea

var original_position: Vector2
var is_triggered := false
var is_falling := false
var player_on_platform := false

func _ready():
	original_position = position
	sprite.play("asleep")
	
	# Connecter les signaux du Area2D
	detection_area.body_entered.connect(_on_body_entered)
	detection_area.body_exited.connect(_on_body_exited)

func _physics_process(delta: float):
	# Si en train de tomber
	if is_falling:
		position.y += fall_speed * delta

func _on_body_entered(body):
	if body.name == "Seb":
		player_on_platform = true
		if not is_triggered and not is_falling:
			trigger_fall()

func _on_body_exited(body):
	if body.name == "Seb":
		player_on_platform = false

func trigger_fall():
	is_triggered = true
	
	# Animation de fissure
	sprite.play("awaken")
	
	# Effet de tremblement
	shake_platform()
	
	# Attendre avant de tomber
	await get_tree().create_timer(crack_delay).timeout
	
	# Commencer à tomber
	start_falling()

func shake_platform():
	var tween := create_tween()
	tween.set_loops(0) # pas de loop implicite

	var step_duration := 0.03
	var steps := int(crack_delay / step_duration)

	for i in range(steps):
		var offset := Vector2(
			randf_range(-shake_intensity, shake_intensity),
			randf_range(-shake_intensity * 0.5, shake_intensity * 0.5)
		)

		tween.tween_property(
			sprite,
			"position",
			offset,
			step_duration
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	# recentrage garanti à la fin
	tween.tween_property(sprite, "position", Vector2.ZERO, 0.08)


func start_falling():
	is_falling = true
	
	# Désactiver la collision
	collision.set_deferred("disabled", true)
	
	# Animation de disparition
	var tween = create_tween()
	tween.tween_property(sprite, "modulate:a", 0.0, 0.5)  # Devient transparent
	
	# Attendre la chute complète
	await get_tree().create_timer(2.0).timeout
	
	# Réapparaître après un délai
	respawn()

func respawn():
	await get_tree().create_timer(respawn_time).timeout
	
	
	# Réinitialiser position
	position = original_position
	sprite.position = Vector2.ZERO
	
	# Réactiver collision
	collision.disabled = false
	
	# Réinitialiser l'apparence
	sprite.play("asleep")
	sprite.modulate.a = 1.0
	
	# Réinitialiser les états
	is_triggered = false
	is_falling = false
	player_on_platform = false
