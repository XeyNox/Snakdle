extends Label

func _process(_delta: float) -> void:
	if GameManager.boss_active:
		text = "Boss en combat !"
	else:
		var remaining := int(ceil(GameManager.time_until_next_boss()))
		text = "Prochain boss : %d s" % remaining
