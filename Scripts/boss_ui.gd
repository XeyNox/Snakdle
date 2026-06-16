extends Control

@onready var hp_bar: ProgressBar = $VBoxContainer/HPBar
@onready var boss_label: Label = $VBoxContainer/BossLabel
@onready var reward_label: Label = $VBoxContainer/RewardLabel

func _ready() -> void:
	GameManager.boss_started.connect(_on_boss_started)
	GameManager.boss_hp_changed.connect(_on_hp_changed)
	GameManager.boss_defeated.connect(_on_boss_defeated)
	hide()

func _on_boss_started(max_hp: float) -> void:
	hp_bar.max_value = max_hp
	hp_bar.value = max_hp
	boss_label.text = "BOSS — Niveau %d" % GameManager.boss_level
	reward_label.text = ""
	show()

func _on_hp_changed(hp: float, _max_hp: float) -> void:
	hp_bar.value = hp

func _on_boss_defeated(gems: int) -> void:
	reward_label.text = "+%d gems !" % gems
	await get_tree().create_timer(1.5).timeout
	hide()
