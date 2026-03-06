extends Node

# Signaux
signal coins_changed(new_amount)
signal health_changed(new_health)
signal player_died
signal token_collected(color)
signal all_tokens_collected

# Variables
var coins: int = 0
var max_health: int = 5
var current_health: int = 5

# NOUVEAU - Jetons
var blue_token: bool = false
var red_token: bool = false
var yellow_token: bool = false
var has_key: bool = false

# === CHECKPOINT ===
var checkpoint_active: bool = false
var checkpoint_position: Vector2 = Vector2.ZERO
var checkpoint_coins: int = 0
var checkpoint_has_key: bool = false
var checkpoint_blue_token: bool = false
var checkpoint_red_token: bool = false
var checkpoint_yellow_token: bool = false

# === COLLECTED COINS (persist across respawn) ===
var collected_coin_ids: Array[String] = []
var checkpoint_collected_coins: Array[String] = []

func _ready():
	current_health = max_health

# === COINS ===
func add_coins(amount: int):
	coins += amount
	coins_changed.emit(coins)

func get_coins() -> int:
	return coins

func reset_coins():
	coins = 0
	coins_changed.emit(coins)

# === HEALTH ===
func take_damage(amount: int = 1):
	current_health -= amount
	current_health = max(0, current_health)
	health_changed.emit(current_health)
	
	if current_health <= 0:
		player_died.emit()

func heal(amount: int = 1):
	current_health += amount
	current_health = min(max_health, current_health)
	health_changed.emit(current_health)

func get_health() -> int:
	return current_health

func reset_health():
	current_health = max_health
	health_changed.emit(current_health)

# === TOKENS ===
func collect_token(color: String):
	match color:
		"blue":
			if not blue_token:
				blue_token = true
				token_collected.emit("blue")
				print("Blue token collected!")
		"red":
			if not red_token:
				red_token = true
				token_collected.emit("red")
				print("Red token collected!")
		"yellow":
			if not yellow_token:
				yellow_token = true
				token_collected.emit("yellow")
				print("Yellow token collected!")
	
	# Vérifier si tous les jetons sont collectés
	if blue_token and red_token and yellow_token:
		all_tokens_collected.emit()
		print("All tokens collected!")

func has_all_tokens() -> bool:
	return blue_token and red_token and yellow_token

func collect_key():
	has_key = true
	print("Key collected!")

func has_the_key() -> bool:
	return has_key

func reset_tokens():
	blue_token = false
	red_token = false
	yellow_token = false
	has_key = false

func save_checkpoint(pos: Vector2):
	checkpoint_active = true
	checkpoint_position = pos
	checkpoint_coins = coins
	checkpoint_has_key = has_key
	checkpoint_blue_token = blue_token
	checkpoint_red_token = red_token
	checkpoint_yellow_token = yellow_token
	checkpoint_collected_coins = collected_coin_ids.duplicate()
	print("Checkpoint saved at ", pos)

func restore_checkpoint_state():
	coins = checkpoint_coins
	coins_changed.emit(coins)
	has_key = checkpoint_has_key
	blue_token = checkpoint_blue_token
	red_token = checkpoint_red_token
	yellow_token = checkpoint_yellow_token
	collected_coin_ids = checkpoint_collected_coins.duplicate()
	reset_health()

func clear_checkpoint():
	checkpoint_active = false
	checkpoint_position = Vector2.ZERO
	checkpoint_coins = 0
	checkpoint_has_key = false
	checkpoint_blue_token = false
	checkpoint_red_token = false
	checkpoint_yellow_token = false
	checkpoint_collected_coins = []

func register_coin_collected(id: String):
	if id not in collected_coin_ids:
		collected_coin_ids.append(id)

func is_coin_collected(id: String) -> bool:
	return id in collected_coin_ids

# === RESET ===
func reset_game():
	reset_coins()
	reset_health()
	reset_tokens()
	clear_checkpoint()
	collected_coin_ids = []
