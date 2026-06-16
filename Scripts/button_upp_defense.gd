extends Button

func _ready() -> void:
	pressed.connect(func(): GameManager.buy_defense_upgrade())

func _process(_delta: float) -> void:
	text = "↑ Défense\n%d$" % GameManager.defense_upgrade_cost
	disabled = GameManager.money < GameManager.defense_upgrade_cost
