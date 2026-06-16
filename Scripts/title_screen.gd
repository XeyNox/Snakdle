extends Node2D

@onready var subtitle_label:  Label          = $CanvasLayer/SubtitleLabel
@onready var play_button:     Button         = $CanvasLayer/PlayButton
@onready var settings_button: Button         = $CanvasLayer/SettingsButton
@onready var settings_panel:  PanelContainer = $CanvasLayer/SettingsPanel

func _ready() -> void:
	match GameManager.screen_state:
		"pause":
			subtitle_label.text = "En pause"
			subtitle_label.show()
			play_button.text = "Reprendre"
		"gameover":
			subtitle_label.text = "Game Over"
			subtitle_label.show()
			play_button.text = "Rejouer"
		_:
			subtitle_label.hide()
			play_button.text = "Jouer"

	play_button.pressed.connect(_on_play_pressed)
	settings_button.pressed.connect(_on_settings_pressed)

func _on_play_pressed() -> void:
	if GameManager.screen_state == "gameover":
		GameManager.reset_game()
	GameManager.screen_state = "playing"
	get_tree().change_scene_to_file("res://Scenes/Main.tscn")

func _on_settings_pressed() -> void:
	settings_panel.visible = not settings_panel.visible
