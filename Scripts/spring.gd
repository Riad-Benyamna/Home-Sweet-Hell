extends AnimatableBody2D

@export var bounce_force := -6500.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_area: Area2D = $CollisionShape2D/Area2D
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D


func _ready():
	animated_sprite.play("idle")
	detection_area.body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Seb" :
		# Vérifier que le joueur vient du dessus
		if body.global_position.y < global_position.y:
			bounce(body)

func bounce(body: CharacterBody2D):
	# Appliquer le saut IMMÉDIATEMENT
	body.velocity.y = bounce_force

	# Animation du ressort
	audio_player.play()
	animated_sprite.play("bounce")
	await animated_sprite.animation_finished
	animated_sprite.play("idle")
