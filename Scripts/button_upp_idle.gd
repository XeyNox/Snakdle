extends Button

func _ready():
	pressed.connect(_on_pressed)

func _process(_delta):
	text = "Upgrade Idle\nCost: " + str(floor(GameManager.idle_upgrade_cost))
	disabled = GameManager.money < GameManager.idle_upgrade_cost

func _on_pressed():
	GameManager.buy_idle_upgrade()
