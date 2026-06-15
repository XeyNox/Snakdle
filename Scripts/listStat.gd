extends TabContainer

# Stats du personnage (variables)
var hp_value = 100
var attaque_value = 100
var defense_value = 100

# Références aux labels (nœuds)
@onready var hp_label = $Statistiques/HP
@onready var attaque_label = $Statistiques/Attaque
@onready var defense_label = $Statistiques/Défense

func _ready():
	print("HP : " + str(hp_value))
	update_stats()

func update_stats():
	hp_label.text = "HP : " + str(hp_value)
	attaque_label.text = "Attaque : " + str(attaque_value)
	defense_label.text = "Défense : " + str(defense_value)
