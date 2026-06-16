extends Button

func _ready() -> void:
	pressed.connect(func(): GameManager.buy_hp_upgrade())

func _process(_delta: float) -> void:
	text = "↑ HP\n%d$" % GameManager.hp_upgrade_cost
	disabled = GameManager.money < GameManager.hp_upgrade_cost
