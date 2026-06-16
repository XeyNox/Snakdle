extends Button

const FloatingText = preload("res://Scenes/FloatingText.tscn")

func _ready():
	pressed.connect(_on_pressed)

func _on_pressed():
	var gold_multi = 1.0 + GachaManager.get_bonus("gold_multiplier")
	GameManager.money += GameManager.money_per_click * gold_multi
	
	var label = FloatingText.instantiate()
	label.text = "+" + str(floor(GameManager.money_per_click))
	label.position = get_viewport().get_mouse_position()
	get_parent().add_child(label)
