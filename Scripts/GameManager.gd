extends Node

#Argent
var money: float = 0.0
var money_per_second: float = 1.0
var money_per_click: float = 1.0
var idle_upgrade_cost: float = 10.0
var click_upgrade_cost: float = 10.0

#Stats du joueur
var player_hp: float = 100.0
var player_max_hp: float = 100.0
var player_attack: float = 10.0
var player_defense: float = 5.0
var player_evasion: float = 0.1

#Cout d'upgrade des stats
var hp_upgrade_cost: float = 25.0
var attack_upgrade_cost: float = 25.0
var defense_upgrade_cost: float = 25.0
var evasion_upgrade_cost: float = 40.0

#Boss
var boss_level: int = 1
var boss_hp: float = 0.0
var boss_max_hp: float = 0.0
var boss_active: bool = false
var _damage_timer: float = 0.0
const DAMAGE_INTERVAL := 2.0

#Screen and audio
var screen_state: String = "start"
var music_volume: float = 1.0
var sfx_volume: float = 1.0

signal boss_started(max_hp: float)
signal boss_hp_changed(hp: float, max_hp: float)
signal boss_defeated(gems_reward: int)
signal player_hp_changed(hp: float, max_hp: float)
signal player_died()

func _process(delta: float) -> void:
	if screen_state == "gameover":
		return
	money += money_per_second * delta

	if not boss_active and money >= _boss_threshold():
		_start_boss()

	if boss_active:
		boss_hp -= player_attack * delta
		boss_hp_changed.emit(boss_hp, boss_max_hp)
		if boss_hp <= 0.0:
			_defeat_boss()
			return

		_damage_timer += delta
		if _damage_timer >= DAMAGE_INTERVAL:
			_damage_timer = 0.0
			_boss_attack_player()

func _boss_threshold() -> float:
	return 50.0 * pow(boss_level, 1.5)

func _start_boss() -> void:
	boss_max_hp = _boss_threshold() * 3.0
	boss_hp = boss_max_hp
	boss_active = true
	_damage_timer = 0.0
	boss_started.emit(boss_max_hp)

func _defeat_boss() -> void:
	var reward := boss_level * 5
	GachaManager.add_gems(reward)
	boss_active = false
	boss_level += 1
	boss_defeated.emit(reward)

func _boss_attack_player() -> void:
	if randf() < player_evasion:
		return
	var raw := float(boss_level) * 12.0 * randf_range(0.7, 1.3)
	var dmg: float = maxf(1.0, raw - player_defense)
	player_hp = maxf(0.0, player_hp - dmg)
	player_hp_changed.emit(player_hp, player_max_hp)
	if player_hp <= 0.0:
		_player_die()

func _player_die() -> void:
	screen_state = "gameover"
	player_died.emit()

func buy_idle_upgrade() -> void:
	if money >= idle_upgrade_cost:
		money -= idle_upgrade_cost
		money_per_second += 0.5
		idle_upgrade_cost *= 1.5

func buy_click_upgrade() -> void:
	if money >= click_upgrade_cost:
		money -= click_upgrade_cost
		money_per_click += 0.5
		click_upgrade_cost *= 1.5

func buy_hp_upgrade() -> void:
	if money >= hp_upgrade_cost:
		money -= hp_upgrade_cost
		player_max_hp += 25.0
		player_hp = player_max_hp
		hp_upgrade_cost *= 1.5
		player_hp_changed.emit(player_hp, player_max_hp)

func buy_attack_upgrade() -> void:
	if money >= attack_upgrade_cost:
		money -= attack_upgrade_cost
		player_attack += 3.0
		attack_upgrade_cost *= 1.5

func buy_defense_upgrade() -> void:
	if money >= defense_upgrade_cost:
		money -= defense_upgrade_cost
		player_defense += 2.0
		defense_upgrade_cost *= 1.5

func buy_evasion_upgrade() -> void:
	if money >= evasion_upgrade_cost:
		money -= evasion_upgrade_cost
		player_evasion = min(player_evasion + 0.05, 0.75)
		evasion_upgrade_cost *= 1.8

func reset_game() -> void:
	screen_state = "start"
	money = 0.0
	money_per_second = 1.0
	money_per_click = 1.0
	idle_upgrade_cost = 10.0
	click_upgrade_cost = 10.0
	player_hp = 100.0
	player_max_hp = 100.0
	player_attack = 10.0
	player_defense = 5.0
	player_evasion = 0.1
	hp_upgrade_cost = 25.0
	attack_upgrade_cost = 25.0
	defense_upgrade_cost = 25.0
	evasion_upgrade_cost = 40.0
	boss_level = 1
	boss_hp = 0.0
	boss_max_hp = 0.0
	boss_active = false
	_damage_timer = 0.0
