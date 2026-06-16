extends Button

func _ready() -> void:
	pressed.connect(_on_pressed)

func _process(_delta: float) -> void:
	text = "Idle: %.1f/s  →  %.1f/s\nCoût: %d$" % [
		GameManager.money_per_second,
		GameManager.money_per_second + 0.5,
		GameManager.idle_upgrade_cost
	]
	disabled = GameManager.money < GameManager.idle_upgrade_cost

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		print("[ButtonUppIdle] reçu clic — disabled=", disabled, " money=", GameManager.money, " cost=", GameManager.idle_upgrade_cost)

func _on_pressed() -> void:
	print("[ButtonUppIdle] _on_pressed appelé !")
	GameManager.buy_idle_upgrade()
