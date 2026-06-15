extends Node

# Ressource d'invocation
var gems: int = 0
const PULL_COST: int = 10

# Définition des personnages par rareté
const CHARACTERS = [
	{ "name": "Goblin",   "rarity": "C", "weight": 60 },
	{ "name": "Archer",   "rarity": "C", "weight": 60 },
	{ "name": "Knight",   "rarity": "B", "weight": 25 },
	{ "name": "Mage",     "rarity": "B", "weight": 25 },
	{ "name": "Dragon",   "rarity": "A", "weight": 8  },
	{ "name": "Phoenix",  "rarity": "S", "weight": 2  },
]

# Collection du joueur : { "nom": nombre_possédé }
var collection: Dictionary = {}

signal pull_done(character: Dictionary)
signal gems_changed(new_amount: int)

func add_gems(amount: int):
	gems += amount
	emit_signal("gems_changed", gems)

func pull() -> Dictionary:
	if gems < PULL_COST:
		return {}

	gems -= PULL_COST
	emit_signal("gems_changed", gems)

	var result = _weighted_random()
	collection[result["name"]] = collection.get(result["name"], 0) + 1
	emit_signal("pull_done", result)
	return result

func _weighted_random() -> Dictionary:
	var total = 0
	for c in CHARACTERS:
		total += c["weight"]

	var roll = randi() % total
	var cumul = 0
	for c in CHARACTERS:
		cumul += c["weight"]
		if roll < cumul:
			return c

	return CHARACTERS[0]  # fallback
