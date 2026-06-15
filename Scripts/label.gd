extends Label

func _process(_delta):
	text = "Money: " + str(floor(GameManager.money))
