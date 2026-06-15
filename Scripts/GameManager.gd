extends Node

var money: float = 0.0
var money_per_second: float = 1.0
var money_per_click: float = 1.0

var idle_upgrade_cost: float = 10.0
var click_upgrade_cost: float = 10.0

func _process(delta):
	money += money_per_second * delta

func buy_idle_upgrade():
	if money >= idle_upgrade_cost:
		money -= idle_upgrade_cost
		money_per_second += 0.5
		idle_upgrade_cost *= 1.5

func buy_click_upgrade():
	if money >= click_upgrade_cost:
		money -= click_upgrade_cost
		money_per_click += 0.5
		click_upgrade_cost *= 1.5
