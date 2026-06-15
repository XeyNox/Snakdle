extends Node

var money: float = 0.0
var money_per_second: float = 1.0
var money_per_click: float = 1.0

var idle_upgrade_cost: float = 10.0
var click_upgrade_cost: float = 10.0

var boss_level: int = 1
var boss_hp: float = 0.0
var boss_max_hp: float = 0.0
var boss_active: bool = false

signal boss_started(max_hp: float)
signal boss_hp_changed(hp: float, max_hp: float)
signal boss_defeated(gems_reward: int)

func _process(delta: float) -> void:
	money += money_per_second * delta

	if not boss_active and money >= _boss_threshold():
		_start_boss()

	if boss_active:
		boss_hp -= money_per_second * delta
		boss_hp_changed.emit(boss_hp, boss_max_hp)
		if boss_hp <= 0.0:
			_defeat_boss()

func _boss_threshold() -> float:
	return 50.0 * pow(boss_level, 1.5)

func _start_boss() -> void:
	boss_max_hp = _boss_threshold() * 3.0
	boss_hp = boss_max_hp
	boss_active = true
	boss_started.emit(boss_max_hp)

func _defeat_boss() -> void:
	var reward := boss_level * 5
	GachaManager.add_gems(reward)
	boss_active = false
	boss_level += 1
	boss_defeated.emit(reward)

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
