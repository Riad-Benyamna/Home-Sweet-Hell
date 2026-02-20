extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Enable saving in VN sections
	SaveManager.enable_saving()

	Dialogic.signal_event.connect(_on_dialogic_signal)
	Dialogic.start("SophiaRoute")

func _on_dialogic_signal(argument: String):
	if argument == "end":
		get_tree().quit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
