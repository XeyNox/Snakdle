extends Button

const FloatingText = preload("res://Scenes/FloatingText.tscn")

func _ready():
	pressed.connect(_on_pressed)

func _on_pressed():
	GameManager.money += GameManager.money_per_click
	
	var label = FloatingText.instantiate()
	label.text = "+" + str(floor(GameManager.money_per_click))
	label.position = get_viewport().get_mouse_position()
	get_parent().add_child(label)
