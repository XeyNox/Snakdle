extends Node2D

@onready var snake: AnimatedSprite2D = $Snake
@onready var boss: AnimatedSprite2D  = $Boss

func _ready() -> void:
	GameManager.boss_started.connect(_on_boss_started)
	GameManager.boss_defeated.connect(_on_boss_defeated)
	GameManager.player_died.connect(_on_player_died)
	boss.visible = false
	_play(snake, "walk")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and GameManager.screen_state == "playing":
		GameManager.screen_state = "pause"
		get_tree().change_scene_to_file("res://Scenes/TitleScreen.tscn")

func _on_boss_started(_max_hp: float) -> void:
	boss.visible = true
	_play(snake, "attack")
	_play(boss, "idle")

func _on_boss_defeated(_gems: int) -> void:
	_play(boss, "death")
	await get_tree().create_timer(1.0).timeout
	boss.visible = false
	_play(snake, "walk")

func _on_player_died() -> void:
	_play(snake, "hurt")
	await get_tree().create_timer(1.0).timeout
	if is_instance_valid(self):
		get_tree().change_scene_to_file("res://Scenes/TitleScreen.tscn")

func _play(sprite: AnimatedSprite2D, anim: String) -> void:
	if sprite.sprite_frames != null and sprite.sprite_frames.has_animation(anim):
		sprite.play(anim)
