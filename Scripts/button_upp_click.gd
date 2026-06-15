extends Button

func _ready():
	pressed.connect(_on_pressed)

func _process(_delta):
	text = "Upgrade Click\nCost: " + str(floor(GameManager.click_upgrade_cost))
	disabled = GameManager.money < GameManager.click_upgrade_cost

func _on_pressed():
	GameManager.buy_click_upgrade()
