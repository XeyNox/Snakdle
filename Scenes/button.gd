extends Button

func _ready():
	pressed.connect(_on_pressed)

func _on_pressed():
	GameManager.money += GameManager.money_per_click
