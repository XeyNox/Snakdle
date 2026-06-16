extends Node2D

signal died

var hp: float = 0.0
var attack: float = 0.0
var target_x: float = 200

const SPEED := 80
const ATTACK_INTERVAL := 3.0
const ATTACK_RANGE := 100.0

var _attack_timer: float = 0.0

func _ready() -> void:
	scale = Vector2.ZERO
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.12)
	tween.tween_property(self, "scale", Vector2.ONE, 0.08)

func setup() -> void:
	hp = 30.0 + GameManager.boss_level * 10
	attack = 5.0 + GameManager.boss_level * 2

func _process(delta: float) -> void:
	if GameManager.screen_state != "playing":
		return
	if abs(position.x - target_x) > ATTACK_RANGE:
		position.x += sign(target_x - position.x) * SPEED * delta
	else:
		_attack_timer += delta
		if _attack_timer >= ATTACK_INTERVAL:
			_attack_timer = 0.0
			_attack_player()

func take_damage(amount: float) -> void:
	hp -= amount
	if hp <= 0.0:
		_die()

func _attack_player() -> void:
	if randf() < GameManager.player_evasion:
		return
	var dmg := maxf(1.0, attack - GameManager.player_defense)
	GameManager.player_hp = maxf(0.0, GameManager.player_hp - dmg)
	GameManager.player_hp_changed.emit(GameManager.player_hp, GameManager.player_max_hp)
	if GameManager.player_hp <= 0.0:
		GameManager._player_die()
	_flash_attack()

func _flash_attack() -> void:
	var rect := $ColorRect
	var tween = create_tween()
	tween.tween_property(rect, "color", Color(1.0, 1.0, 0.0, 1.0), 0.08)
	tween.tween_property(rect, "color", Color(0.8, 0.1, 0.1, 1.0), 0.12)

func _die() -> void:
	if randi() % 2 == 0:
		GameManager.player_attack += 0.5
	else:
		GameManager.player_defense += 0.3
	died.emit()
	queue_free()
