extends Button

func _ready() -> void:
	pressed.connect(func(): GameManager.buy_attack_upgrade())

func _process(_delta: float) -> void:
	text = "↑ Attaque\n%d$" % GameManager.attack_upgrade_cost
	disabled = GameManager.money < GameManager.attack_upgrade_cost
