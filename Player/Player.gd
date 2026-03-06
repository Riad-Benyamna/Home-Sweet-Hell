extends CharacterBody2D

#region Player Variables
# Nodes
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var collider: CollisionShape2D = $Collider
@onready var States: Node = $StateMachine
@onready var camera: Camera2D = $Camera
@onready var jump_buffer: Timer = $Timers/JumpBufferTimer
@onready var coyote_timer: Timer = $Timers/CoyoteTimer
@export var zoom := Vector2(0.5,0.5)
@export var camera_position := Vector2(30,-287)


#Physics variables
const CLIMB_SPEED = 600.0
const RunSpeed = 1400
const Acceleration = 30
const Deceleration = 50
const GravityJump = 4500
const GravityFall = 5500
const MaxFallVelocity = 4000
const JumpVelocity = -2200  
const VariableJumpMultiplier = 0.5
const MaxJumps = 1
const JumpBufferTime = 0.1 # 6 frames
const CoyoteTime = 0.1 # 6 Frames


var moveSpeed = RunSpeed
var jumpSpeed = JumpVelocity
var moveDirectionX = 0
var jumps = 0
var facing = 1

# NOUVEAU - compteur de contact avec l’échelle
var ladder_count := 0

#Input Variables
var keyUp = false
var keyDown = false
var keyLeft = false
var keyRight = false
var keyJump = false
var keyJumpPressed = false

#State Machine
var currentState = null
var prevState = null

# NOUVEAU - Variables de dégâts
var is_invincible: bool = false
var invincibility_duration: float = 1.0
@onready var invincibility_timer: Timer = Timer.new()
var is_hurt: bool = false
#endregion

#region Main Loop Functions
func _ready():
	#Initialize state machine
	for state in States.get_children():
		state.States = States 
		state.Player = self 
		
	camera.position = camera_position
	camera.zoom = zoom
	
	prevState = States.fall
	currentState = States.fall
	add_child(invincibility_timer)
	invincibility_timer.one_shot = true
	invincibility_timer.timeout.connect(_on_invincibility_timeout)
	GameManager.player_died.connect(_on_player_died)

	# Respawn at checkpoint if one is active
	if GameManager.checkpoint_active:
		global_position = GameManager.checkpoint_position

func _draw() -> void:
	currentState.Draw()
	
func _physics_process(delta: float) -> void:
	# Get Input States
	GetInputStates()
	if is_hurt:
		velocity.x = 0
		move_and_slide()
		return
	
	# Si on est sur l’échelle et qu’on est dans le state climb
	if is_on_ladder() and currentState == States.climb:
		velocity.y = Input.get_axis("up", "down") * CLIMB_SPEED
	
	if is_invincible:
		sprite.modulate.a = abs(sin(Time.get_ticks_msec() / 100.0))
	else:
		sprite.modulate.a = 1.0
	
	#Update Current State
	currentState.Update(delta)
	
	#Handle Movements
	HandleMaxFallVelocity()
	HandleJump()
	HorizontalMovement()
	
	#Commit Movement
	move_and_slide()
	
func ChangeState(newState): 
	if (newState != null):
		prevState = currentState
		currentState = newState
		prevState.ExitState()
		currentState.EnterState()
		return
#endregion

#region Custom Functions
func GetInputStates():
	keyUp = Input.is_action_just_pressed("up")
	keyDown = Input.is_action_just_pressed("down")
	keyLeft = Input.is_action_just_pressed("left")
	keyRight = Input.is_action_just_pressed("right")
	keyJump = Input.is_action_pressed("jump")
	keyJumpPressed = Input.is_action_just_pressed("jump")
	
	if keyRight: facing = 1
	if keyLeft: facing = -1
	
	# Entrer sur l'échelle
	if is_on_ladder() and currentState != States.climb:
		if keyUp or keyDown:
			ChangeState(States.climb)
	
func HorizontalMovement(acceleration: float = Acceleration, deceleration: float = Deceleration):
	moveDirectionX = Input.get_axis("left","right")
	if moveDirectionX != 0:
		velocity.x = move_toward(velocity.x, moveDirectionX * moveSpeed, acceleration)
	else:
		velocity.x = move_toward(velocity.x, 0, deceleration)

func take_damage(amount: int = 1):
	if is_invincible or is_hurt:
		return
	
	# Retirer la vie
	GameManager.take_damage(amount)
	
	# Si pas mort, jouer l'animation hurt
	if GameManager.get_health() > 0:
		play_hurt_animation()
	
func play_hurt_animation():
	is_hurt = true
	is_invincible = true
	
	# Jouer l'animation (si vous en avez une)
	if sprite.sprite_frames.has_animation("hurt"):
		sprite.play("hurt")
	else:
		# Sinon, effet de recul simple
		velocity.x = -facing * 300  # Recul dans la direction opposée
		velocity.y = -200
	
	# Arrêter le joueur pendant un court instant
	await get_tree().create_timer(0.5).timeout
	
	is_hurt = false
	
	# Démarrer l'invincibilité
	invincibility_timer.start(invincibility_duration)

func _on_invincibility_timeout():
	is_invincible = false
	sprite.modulate.a = 1.0

func _on_player_died():
	print("Player is dead!")
	# Désactiver les contrôles
	set_physics_process(false)
	
	# Animation de mort (si vous en avez)
	if sprite.sprite_frames.has_animation("death"):
		sprite.play("death")
		await sprite.animation_finished
	
	# Effet de slow motion
	Engine.time_scale = 0.5
	await get_tree().create_timer(0.5).timeout
	Engine.time_scale = 1.0
	
	# Recharger la scène
	if GameManager.checkpoint_active:
		print("=== CHECKPOINT RESTORE ===")
		print("Coins: ", GameManager.checkpoint_coins)
		print("Key: ", GameManager.checkpoint_has_key)
		print("Blue token: ", GameManager.checkpoint_blue_token)
		print("Red token: ", GameManager.checkpoint_red_token)
		print("Yellow token: ", GameManager.checkpoint_yellow_token)
		GameManager.restore_checkpoint_state()
	else:
		print("=== NO CHECKPOINT - full reset ===")
		GameManager.reset_game()
	get_tree().reload_current_scene()
	
func HandleFalling():
	if is_on_ladder(): return
	if !is_on_floor():
		coyote_timer.start(CoyoteTime)
		ChangeState(States.fall)
		
func HandleJumpBuffer():
	if keyJumpPressed:
		jump_buffer.start(JumpBufferTime)
		
func HandleMaxFallVelocity():
	if velocity.y > MaxFallVelocity:
		velocity.y = MaxFallVelocity
	
func HandleLanding():
	if is_on_ladder(): return
	if is_on_floor():
		jumps = 0
		ChangeState(States.idle)
	
func HandleGravity(delta, gravity: float = GravityJump):
	if is_on_ladder(): return
	if !is_on_floor():
		velocity.y += gravity * delta
		
func HandleJump():
	if is_on_ladder(): return
	if is_on_floor() and jumps < MaxJumps:
		if keyJumpPressed or jump_buffer.time_left > 0:
			jump_buffer.stop()
			jumps +=1
			ChangeState(States.jump)
	else:
		# Handle Air Jump if Max Jump > 1
		if jumps > 0 and jumps < MaxJumps and keyJumpPressed:
			jumps += 1
			ChangeState(States.jump)
		#Handle Coyote Time Jumps
		if coyote_timer.time_left > 0 and jumps < MaxJumps and keyJumpPressed:
			jumps +=1
			ChangeState(States.jump)
			
func HandleFlipH():
	sprite.flip_h = (facing < 1)

# NOUVEAU - méthode pour vérifier ladder
func is_on_ladder() -> bool:
	return ladder_count > 0
#endregion
