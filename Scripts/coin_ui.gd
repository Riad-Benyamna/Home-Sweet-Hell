extends CanvasLayer

@onready var coin_label = $CoinLabel

func _ready():
	# Se connecter au signal du GameManager
	GameManager.coins_changed.connect(_on_coins_changed)
	
	# Afficher le montant initial
	update_display(GameManager.get_coins())

func _on_coins_changed(new_amount: int):
	update_display(new_amount)

func update_display(amount: int):
	coin_label.text = "x" + str(amount)
