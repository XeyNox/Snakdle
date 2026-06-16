extends Button

func _ready() -> void:
	pressed.connect(func(): GameManager.buy_evasion_upgrade())

func _process(_delta: float) -> void:
	text = "↑ Esquive\n%d$" % GameManager.evasion_upgrade_cost
	disabled = GameManager.money < GameManager.evasion_upgrade_cost
