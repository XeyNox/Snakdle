extends Control

@onready var color_rect = $PanelContainer/VBoxContainer/ColorRect
@onready var name_label = $PanelContainer/VBoxContainer/Label

const RARITY_COLORS = {
	"Common":       Color.WHITE,
	"Uncommun":     Color(0.3, 0.8, 0.3),
	"Rare":         Color(0.3, 0.6, 1.0),
	"Epic":         Color(0.7, 0.3, 1.0),
	"Legendary":    Color(1.0, 0.7, 0.0),
	"FrenchMonster":Color(1.0, 0.1, 0.1),
}

func setup(character: Dictionary):
	name_label.text = character["name"]
	color_rect.color = RARITY_COLORS[character["rarity"]]
