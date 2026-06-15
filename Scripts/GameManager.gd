extends Node

var money: float = 0.0
var money_per_second: float = 0.5
var money_per_click: float = 1.5
var idle_upgrade_cost: float = 8.0
var click_upgrade_cost: float = 12.0

var rebirth_count: int = 0
var rebirth_multiplier: float = 1.0

func _process(delta):
	money += money_per_second * rebirth_multiplier * delta

func buy_idle_upgrade():
	if money >= idle_upgrade_cost:
		money -= idle_upgrade_cost
		money_per_second += 0.4
		idle_upgrade_cost *= 1.3

func buy_click_upgrade():
	if money >= click_upgrade_cost:
		money -= click_upgrade_cost
		money_per_click += 0.8
		click_upgrade_cost *= 1.35

func rebirth():
	rebirth_count += 1
	rebirth_multiplier += 0.5
	money = 0.0
	money_per_second = 0.5
	money_per_click = 1.5
	idle_upgrade_cost = 8.0
	click_upgrade_cost = 12.0
