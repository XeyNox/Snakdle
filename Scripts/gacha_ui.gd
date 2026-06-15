extends Control

@onready var gems_label = $VBoxContainer/GemsLabel
@onready var pull_button = $VBoxContainer/PullButton
@onready var result_label = $VBoxContainer/ResultLabel

const RARITY_COLORS = {
	"C": Color.WHITE,
	"B": Color(0.3, 0.6, 1.0),    # bleu
	"A": Color(1.0, 0.7, 0.0),    # doré
	"S": Color(1.0, 0.3, 1.0),    # violet
}

func _ready():
	GachaManager.gems_changed.connect(_on_gems_changed)
	GachaManager.pull_done.connect(_on_pull_done)
	GachaManager.add_gems(50)  # gems de départ pour tester

func _on_pull_button_pressed():
	var result = GachaManager.pull()
	if result.is_empty():
		result_label.text = "Pas assez de gems ! (10 requis)"
		result_label.modulate = Color.RED

func _on_pull_done(character: Dictionary):
	result_label.text = "[%s] %s" % [character["rarity"], character["name"]]
	result_label.modulate = RARITY_COLORS[character["rarity"]]

func _on_gems_changed(amount: int):
	gems_label.text = "Gems : %d" % amount
