extends Button

func _ready():
	pressed.connect(_on_pressed)

func _on_pressed():
	GameManager.on_boss_page = true
	get_tree().change_scene_to_file("res://Scenes/BossUI.tscn")
