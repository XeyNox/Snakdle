extends Button

func _ready() -> void:
	pressed.connect(_on_pressed)

func _process(_delta: float) -> void:
	text = "Clic: %.1f  →  %.1f\nCoût: %d$" % [
		GameManager.money_per_click,
		GameManager.money_per_click + 0.5,
		GameManager.click_upgrade_cost
	]
	disabled = GameManager.money < GameManager.click_upgrade_cost

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		print("[ButtonUppClick] reçu clic — disabled=", disabled, " money=", GameManager.money, " cost=", GameManager.click_upgrade_cost)

func _on_pressed() -> void:
	print("[ButtonUppClick] _on_pressed appelé !")
	GameManager.buy_click_upgrade()
