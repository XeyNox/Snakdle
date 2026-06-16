extends Node2D

@onready var snake: Sprite2D = $Snake
@onready var boss: AnimatedSprite2D = $Boss
@onready var enemy_manager = $EnemyManager

func _ready() -> void:
	GameManager.boss_started.connect(_on_boss_started)
	GameManager.boss_defeated.connect(_on_boss_defeated)
	GameManager.player_died.connect(_on_player_died)
	GachaManager.skin_equipped.connect(_on_skin_equipped)
	boss.visible = false
	_pick_next_target()
	if GachaManager.equipped_skin != "":
		_apply_skin(GachaManager.equipped_skin)
	
func _pick_next_target() -> void:
	var vp := get_viewport_rect().size
	var target_x := randf_range(50.0, vp.x - 50.0)
	var target_y := randf_range(150.0, vp.y - 100.0)
	var dist := (Vector2(target_x, target_y) - snake.position).length()
	var duration := dist / 150.0
	snake.flip_h = target_x < snake.position.x

	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(snake, "position:x", target_x, duration)
	tween.tween_property(snake, "position:y", target_y, duration)
	tween.chain().tween_interval(randf_range(0.5, 2.0))
	tween.chain().tween_callback(_pick_next_target)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and GameManager.screen_state == "playing":
		GameManager.screen_state = "pause"
		get_tree().change_scene_to_file("res://Scenes/TitleScreen.tscn")

func _on_boss_started(_max_hp: float) -> void:
	boss.visible = true
	_play(boss, "idle")
	enemy_manager.pause_spawning()

func _on_boss_defeated(_gems: int) -> void:
	_play(boss, "death")
	await get_tree().create_timer(1.0).timeout
	boss.visible = false
	enemy_manager.resume_spawning()

func _on_player_died() -> void:
	await get_tree().create_timer(1.0).timeout
	if is_instance_valid(self):
		get_tree().change_scene_to_file("res://Scenes/TitleScreen.tscn")

func _play(sprite: AnimatedSprite2D, anim: String) -> void:
	if sprite.sprite_frames != null and sprite.sprite_frames.has_animation(anim):
		sprite.play(anim)

func _on_skin_equipped(skin_name: String) -> void:
	_apply_skin(skin_name)

func _apply_skin(skin_name: String) -> void:
	for character in GachaManager.CHARACTERS:
		if character["name"] == skin_name:
			var tex = load(character["image"])
			if tex:
				snake.texture = tex
			break
