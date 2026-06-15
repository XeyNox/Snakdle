extends Control

@onready var gems_label = $VBoxContainer/ColorRect/GemsLabel
@onready var pull_button = $VBoxContainer/ColorRect/PullButton
@onready var result_label = $VBoxContainer/ColorRect/ResultLabel
@onready var grid = $VBoxContainer/ScrollContainer/GridContainer

const SkinCard = preload("res://Scenes/SkinCard.tscn")

const RARITY_COLORS = {
	"Common":       Color.WHITE,
	"Uncommun":     Color(0.3, 0.8, 0.3),
	"Rare":         Color(0.3, 0.6, 1.0),
	"Epic":         Color(0.7, 0.3, 1.0),
	"Legendary":    Color(1.0, 0.7, 0.0),
	"FrenchMonster":Color(1.0, 0.1, 0.1),
}

func _ready():
	GachaManager.gems_changed.connect(_on_gems_changed)
	GachaManager.pull_done.connect(_on_pull_done)
	pull_button.pressed.connect(_on_pull_button_pressed)
	GachaManager.add_gems(5000)
	_refresh_collection()

func _refresh_collection():
	for child in grid.get_children():
		child.queue_free()
	for character in GachaManager.CHARACTERS:
		var card = SkinCard.instantiate()
		grid.add_child(card)
		card.setup(character)

func _on_pull_button_pressed():
	var result = GachaManager.pull()
	if result.is_empty():
		result_label.text = "Pas assez de gems ! (10 requis)"
		result_label.modulate = Color.RED

func _on_pull_done(character: Dictionary):
	result_label.text = "[%s] %s" % [character["rarity"], character["name"]]
	result_label.modulate = RARITY_COLORS[character["rarity"]]
	_refresh_collection()

func _on_gems_changed(amount: int):
	gems_label.text = "Gems : %d" % amount
