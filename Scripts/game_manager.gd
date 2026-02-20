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

# === RESET ===
func reset_game():
	reset_coins()
	reset_health()
	reset_tokens()
