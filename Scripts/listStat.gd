extends TabContainer

# Références aux labels (nœuds)
@onready var hp_label = $Statistiques/HP
@onready var attaque_label = $Statistiques/Attaque
@onready var defense_label = $Statistiques/Défense
@onready var esquive_label = $Statistiques/Esquive

func _ready() -> void:
	GameManager.player_hp_changed.connect(_on_hp_changed)
	update_stats()

func _process(_delta: float) -> void:
	update_stats()

func update_stats() -> void:
	var atq_bonus = GachaManager.get_bonus("atq")
	var def_bonus = GachaManager.get_bonus("def")
	var dodge_bonus = GachaManager.get_bonus("dodge")
	var hp_bonus = GachaManager.get_bonus("hp")
	hp_label.text = "HP : %d / %d" % [GameManager.player_hp, GameManager.player_max_hp + hp_bonus]
	attaque_label.text = "Attaque : %.1f" % [GameManager.player_attack + atq_bonus]
	defense_label.text = "Défense : %.1f" % [GameManager.player_defense + def_bonus]
	esquive_label.text = "Esquive : %d%%" % [int((GameManager.player_evasion + dodge_bonus) * 100)]

func _on_hp_changed(_hp: float, _max: float) -> void:
	update_stats()
