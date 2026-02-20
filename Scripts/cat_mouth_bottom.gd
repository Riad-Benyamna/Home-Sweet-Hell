extends Node2D

@export var distance := 700.0
@export var speed_up := 4000.0     # Montée rapide
@export var speed_down := 400.0    # Descente lente
@export var pause_time := 0.5
@export var shake_amplitude := 14.0
@export var shake_duration := 0.5

@export var start_delay := 0.0     # Retard d’activation par instance

var start_position: Vector2
var going_down := false
var is_paused := false
var pause_at_top := false

var shake_timer := 0.0
var pause_timer := 0.0
var delay_timer := 0.0
var is_active := false

func _ready():
	start_position = position
	delay_timer = start_delay
	is_active = (start_delay <= 0.0)

func _physics_process(delta):
	# Phase d’attente avant activation
	if not is_active:
		delay_timer -= delta
		if delay_timer <= 0:
			is_active = true
		else:
			return

	if is_paused:
		# Phase shake
		if shake_timer > 0:
			shake_timer -= delta
			var t = shake_timer / shake_duration
			var base_y = start_position.y - distance if pause_at_top else start_position.y
			position.y = base_y + sin(t * PI * 4) * shake_amplitude * t
			return
		
		# Phase pause immobile
		pause_timer -= delta
		if pause_timer <= 0:
			is_paused = false
			going_down = pause_at_top
		return

	if going_down:
		# Descente lente
		position.y += speed_down * delta
		if position.y >= start_position.y:
			position.y = start_position.y
			_start_pause(false)
	else:
		# Montée rapide
		position.y -= speed_up * delta
		if position.y <= start_position.y - distance:
			position.y = start_position.y - distance
			_start_pause(true)

func _start_pause(at_top: bool):
	is_paused = true
	pause_at_top = at_top
	shake_timer = shake_duration
	pause_timer = pause_time
