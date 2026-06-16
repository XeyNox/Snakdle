extends Node

var gems: int = 0
const PULL_COST: int = 10
const MAX_LEVEL: int = 999

const CHARACTERS = [
	{ "name": "Goblin",   "rarity": "Common",       "weight": 60 },
	{ "name": "Archer",   "rarity": "Common",        "weight": 60 },
	{ "name": "Knight",   "rarity": "Uncommun",      "weight": 25 },
	{ "name": "Mage",     "rarity": "Rare",          "weight": 25 },
	{ "name": "Dragon",   "rarity": "Legendary",     "weight": 8  },
	{ "name": "Phoenix",  "rarity": "FrenchMonster", "weight": 2  },
]

# collection : { "Goblin": { "level": 1, "xp": 0 }, … }
var collection: Dictionary = {}

signal pull_done(character: Dictionary)
signal gems_changed(new_amount: int)
signal collection_updated()

func add_gems(amount: int) -> void:
	gems += amount
	emit_signal("gems_changed", gems)

# Doublons nécessaires pour passer du niveau N au niveau N+1
func xp_needed_for_next_level(current_level: int) -> int:
	return current_level  # niv 1→2 : 1 doublon, niv 2→3 : 2, etc.

func pull() -> Dictionary:
	if gems < PULL_COST:
		return {}
	gems -= PULL_COST
	emit_signal("gems_changed", gems)
	var result = _weighted_random()
	_add_to_collection(result["name"])
	emit_signal("pull_done", result)
	return result

func _add_to_collection(char_name: String) -> void:
	if not collection.has(char_name):
		collection[char_name] = { "level": 1, "xp": 0 }
		emit_signal("collection_updated")
		return

	var entry = collection[char_name]
	if entry["level"] >= MAX_LEVEL:
		emit_signal("collection_updated")
		return

	entry["xp"] += 1
	var needed = xp_needed_for_next_level(entry["level"])
	while entry["xp"] >= needed and entry["level"] < MAX_LEVEL:
		entry["xp"] -= needed
		entry["level"] += 1
		needed = xp_needed_for_next_level(entry["level"])

	emit_signal("collection_updated")

func get_entry(char_name: String) -> Dictionary:
	if collection.has(char_name):
		return collection[char_name]
	return {}

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
	return CHARACTERS[0]
