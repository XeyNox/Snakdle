extends Node

var money: float = 0.0
var money_per_second: float = 1.0  # passive income
var money_per_click: float = 1.0   # clicking income

func _ready():
	# This runs when the game starts
	pass
	
func _process(delta):
	# delta = time in seconds since last frame
	# This gives smooth passive income regardless of framerate
	money += money_per_second * delta
