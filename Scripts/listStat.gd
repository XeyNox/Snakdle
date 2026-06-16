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
	hp_label.text = "HP : %d / %d" % [GameManager.player_hp, GameManager.player_max_hp]
	attaque_label.text = "Attaque : %.1f  (coût : %d)" % [GameManager.player_attack, GameManager.attack_upgrade_cost]
	defense_label.text = "Défense : %.1f  (coût : %d)" % [GameManager.player_defense, GameManager.defense_upgrade_cost]
	esquive_label.text = "Esquive : %d%%  (coût : %d)" % [int(GameManager.player_evasion * 100), GameManager.evasion_upgrade_cost]

func _on_hp_changed(_hp: float, _max: float) -> void:
	update_stats()
