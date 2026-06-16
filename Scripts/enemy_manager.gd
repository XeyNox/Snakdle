extends Node2D

const EnemyScene = preload("res://Scenes/Enemy.tscn")
const MAX_ENEMIES := 3

var _enemies: Array = []
var _spawn_timer: float = 0.0
var _next_spawn_time: float = 0.0
var _paused: bool = false

func _ready() -> void:
	_reset_spawn_timer()

func _process(delta: float) -> void:
	if _paused or GameManager.screen_state == "gameover":
		return

	if _enemies.size() > 0 and is_instance_valid(_enemies[0]):
		_enemies[0].take_damage(GameManager.player_attack * delta)

	_spawn_timer += delta
	if _spawn_timer >= _next_spawn_time and _enemies.size() < MAX_ENEMIES:
		_spawn_enemy()
		_reset_spawn_timer()

func pause_spawning() -> void:
	_paused = true
	for enemy in _enemies:
		if is_instance_valid(enemy):
			enemy.queue_free()
	_enemies.clear()

func resume_spawning() -> void:
	_paused = false
	_reset_spawn_timer()

func _spawn_enemy() -> void:
	var enemy = EnemyScene.instantiate()
	var vp_width: float = get_viewport_rect().size.x
	if randi() % 2 == 0:
		enemy.position = Vector2(-50.0, 450.0)
	else:
		enemy.position = Vector2(vp_width + 50.0, 450.0)
	enemy.setup()
	enemy.died.connect(_on_enemy_died.bind(enemy))
	add_child(enemy)
	_enemies.append(enemy)

func _on_enemy_died(enemy: Node2D) -> void:
	_enemies.erase(enemy)

func _reset_spawn_timer() -> void:
	_spawn_timer = 0.0
	_next_spawn_time = randf_range(3.0, 7.0)
