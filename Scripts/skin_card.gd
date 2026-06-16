extends Control

@onready var color_rect  = $PanelContainer/VBoxContainer/ColorRect
@onready var name_label  = $PanelContainer/VBoxContainer/NameLabel
@onready var level_label = $PanelContainer/VBoxContainer/LevelLabel
@onready var xp_bar      = $PanelContainer/VBoxContainer/XPBar
@onready var xp_label    = $PanelContainer/VBoxContainer/XPLabel
@onready var equip_button = $PanelContainer/VBoxContainer/EquipButton

const RARITY_COLORS = {
	"Common":        Color.WHITE,
	"Uncommon":      Color(0.3, 0.8, 0.3),
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
	if character.has("image"):
		var tex = load(character["image"])
		if tex:
			var tr = color_rect.get_node_or_null("TextureRect")
			if tr == null:
				tr = TextureRect.new()
				tr.name = "TextureRect"
				tr.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
				tr.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
				tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
				color_rect.add_child(tr)
			tr.texture = tex
	equip_button.pressed.connect(_on_equip_pressed)
	GachaManager.skin_equipped.connect(_on_skin_equipped)
	GachaManager.collection_updated.connect(_on_collection_updated)
	_refresh()

func _refresh() -> void:
	var entry = GachaManager.get_entry(_char_name)
	if entry.is_empty():
		level_label.text = "—"
		xp_bar.visible = false
		xp_label.visible = false
		color_rect.modulate = Color(0.4, 0.4, 0.4, 1.0)
		equip_button.text = "Locked"
		equip_button.disabled = true
	else:
		var lvl: int = entry["level"]
		var xp:  int = entry["xp"]
		color_rect.modulate = Color.WHITE
		equip_button.disabled = false
		if GachaManager.equipped_skin == _char_name:
			equip_button.text = "Equipped ✓"
			equip_button.disabled = true
		else:
			equip_button.text = "Equip"
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

func _on_equip_pressed() -> void:
	GachaManager.equip(_char_name)

func _on_collection_updated() -> void:
	_refresh()

func _on_skin_equipped(_name: String) -> void:
	_refresh()
