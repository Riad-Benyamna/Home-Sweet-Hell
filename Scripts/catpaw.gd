extends Node2D

@export var distance := 700.0        # Hauteur à parcourir
@export var speed_up := 300.0         # Montée lente
@export var speed_down := 3000.0      # Descente rapide
@export var pause_time := 1.5        # Pause en bas
@export var shake_amplitude := 9.0  # Amplitude max du shake
@export var shake_duration := 1    # Durée du rebond/shake
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D


var start_position: Vector2
var going_up := false
var is_paused := false
var shake_timer := 0.0

func _ready():
	start_position = position

func _physics_process(delta):
	if is_paused:
		# Si on est en train de shake/pause
		if shake_timer > 0:
			shake_timer -= delta
			# Oscillation décroissante type “rebond”
			var t = shake_timer / shake_duration
			position.y = start_position.y + sin(t * PI * 4) * shake_amplitude * t
		else:
			# Fin du shake, on repart monter
			position.y = start_position.y
			is_paused = false
			going_up = true
		return

	if going_up:
		# Monter lentement
		position.y -= speed_up * delta
		if position.y <= start_position.y - distance:
			going_up = false
	else:
		# Descendre rapidement
		position.y += speed_down * delta
		if position.y >= start_position.y:
			# Début du shake/pause
			audio_player.play()
			is_paused = true
			shake_timer = shake_duration
