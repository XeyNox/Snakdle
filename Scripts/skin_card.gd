extends Control

@onready var color_rect  = $PanelContainer/VBoxContainer/ColorRect
@onready var name_label  = $PanelContainer/VBoxContainer/NameLabel
@onready var level_label = $PanelContainer/VBoxContainer/LevelLabel
@onready var xp_bar      = $PanelContainer/VBoxContainer/XPBar
@onready var xp_label    = $PanelContainer/VBoxContainer/XPLabel

const RARITY_COLORS = {
	"Common":        Color.WHITE,
	"Uncommun":      Color(0.3, 0.8, 0.3),
	"Rare":          Color(0.3, 0.6, 1.0),
	"Epic":          Color(0.7, 0.3, 1.0),
	"Legendary":     Color(1.0, 0.7, 0.0),
	"FrenchMonster": Color(1.0, 0.1, 0.1),
}

var _char_name: String = ""

func setup(character: Dictionary) -> void:
	_char_name = character["name"]
	name_label.text = character["name"]
	color_rect.color = RARITY_COLORS[character["rarity"]]
	_refresh()
	GachaManager.collection_updated.connect(_on_collection_updated)

func _refresh() -> void:
	var entry = GachaManager.get_entry(_char_name)
	if entry.is_empty():
		level_label.text = "—"
		xp_bar.visible = false
		xp_label.visible = false
		color_rect.modulate = Color(0.4, 0.4, 0.4, 1.0)
	else:
		var lvl: int = entry["level"]
		var xp:  int = entry["xp"]
		color_rect.modulate = Color.WHITE
		if lvl >= GachaManager.MAX_LEVEL:
			level_label.text = "Niv. MAX"
			xp_bar.visible = true
			xp_bar.max_value = 1
			xp_bar.value = 1
			xp_label.visible = true
			xp_label.text = "MAX"
		else:
			var needed: int = GachaManager.xp_needed_for_next_level(lvl)
			level_label.text = "Niv. %d" % lvl
			xp_bar.visible = true
			xp_bar.max_value = needed
			xp_bar.value = xp
			xp_label.visible = true
			xp_label.text = "%d / %d" % [xp, needed]

func _on_collection_updated() -> void:
	_refresh()
