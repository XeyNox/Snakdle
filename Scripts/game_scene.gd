extends Node2D

@onready var snake: Sprite2D = $Snake
@onready var boss: Sprite2D = $Boss
@onready var enemy_manager = $EnemyManager

var _snake_home: Vector2
var _movement_tween: Tween = null

func _ready() -> void:
	GameManager.boss_started.connect(_on_boss_started)
	GameManager.boss_defeated.connect(_on_boss_defeated)
	GameManager.player_died.connect(_on_player_died)
	GachaManager.skin_equipped.connect(_on_skin_equipped)
	boss.visible = false
	_snake_home = snake.position
	if GachaManager.equipped_skin != "":
		_apply_skin(GachaManager.equipped_skin)
	if GameManager.boss_active:
		_setup_active_boss()
	else:
		_pick_next_target()

func _setup_active_boss() -> void:
	boss.visible = true
	boss.flip_h = true
	snake.flip_h = false
	enemy_manager.pause_spawning()
	snake.position = Vector2(500.0, _snake_home.y)
	boss.position = Vector2(700.0, 420.0)

func _pick_next_target() -> void:
	var vp := get_viewport_rect().size
	var target_x := randf_range(50.0, 400.0)
	var target_y := randf_range(150.0, vp.y - 100.0)
	var dist := (Vector2(target_x, target_y) - snake.position).length()
	var duration := dist / 150.0
	snake.flip_h = target_x < snake.position.x

	_movement_tween = create_tween()
	_movement_tween.set_parallel(true)
	_movement_tween.tween_property(snake, "position:x", target_x, duration)
	_movement_tween.tween_property(snake, "position:y", target_y, duration)
	_movement_tween.chain().tween_interval(randf_range(0.5, 2.0))
	_movement_tween.chain().tween_callback(_pick_next_target)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and GameManager.screen_state == "playing":
		GameManager.screen_state = "pause"
		get_tree().change_scene_to_file("res://Scenes/TitleScreen.tscn")

func _on_boss_started(_max_hp: float) -> void:
	if _movement_tween:
		_movement_tween.kill()
	boss.visible = true
	boss.flip_h = true
	snake.flip_h = false
	enemy_manager.pause_spawning()
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(snake, "position", Vector2(500.0, _snake_home.y), 0.8)
	tween.tween_property(boss, "position", Vector2(700.0, 420.0), 0.8)

func _on_boss_defeated(_gems: int) -> void:
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(snake, "position", _snake_home, 0.8)
	tween.tween_property(boss, "position", Vector2(900.0, 420.0), 0.8)
	tween.chain().tween_callback(func():
		if not is_instance_valid(self):
			return
		boss.visible = false
		enemy_manager.resume_spawning()
		_pick_next_target()
	)

func _on_player_died() -> void:
	if _movement_tween:
		_movement_tween.kill()
	await get_tree().create_timer(1.0).timeout
	if is_instance_valid(self):
		get_tree().change_scene_to_file("res://Scenes/TitleScreen.tscn")

func _on_skin_equipped(skin_name: String) -> void:
	_apply_skin(skin_name)

func _apply_skin(skin_name: String) -> void:
	for character in GachaManager.CHARACTERS:
		if character["name"] == skin_name:
			var tex = load(character["image"])
			if tex:
				snake.texture = tex
			break
