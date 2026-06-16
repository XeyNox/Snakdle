extends Node

var gems: int = 0
const PULL_COST: int = 10
const MAX_LEVEL: int = 999

const CHARACTERS = [
	{ "name": "Serpent Gris",   "rarity": "Common",       "weight": 60, "bonus": { "gold_multiplier": 0.1 }, "image":"res://assets/serpent_gris.png" },
	{ "name": "Serpent Vert",   "rarity": "Uncommon",        "weight": 60, "bonus": { "atq": 5.0 }, "image":"res://assets/serpent_uncommun.png" },
	{ "name": "Serpent Bleu",   "rarity": "Rare",      "weight": 25, "bonus": { "def": 10.0 }, "image":"res://assets/serpent_rare.png" },
	{ "name": "Serpent Violet",     "rarity": "Epic",          "weight": 25, "bonus": { "gold_multiplier": 0.25 }, "image":"res://assets/serpent_epic.png" },
	{ "name": "Serpent Doré",   "rarity": "Legendary",     "weight": 8,  "bonus": { "gold_multiplier": 0.5 }, "image":"res://assets/serpent_gold.png" },
	{ "name": "Serpent Monstre",  "rarity": "FrenchMonster", "weight": 2,  "bonus": { "atq": 50.0, "gold_multiplier": 1.0 }, "image":"res://assets/serpent_frenchmonster.png" },
]

var collection: Dictionary = {}
var equipped_skin: String = ""

signal pull_done(character: Dictionary)
signal gems_changed(new_amount: int)
signal collection_updated()
signal skin_equipped(skin_name: String)

func add_gems(amount: int) -> void:
	gems += amount
	emit_signal("gems_changed", gems)

func xp_needed_for_next_level(current_level: int) -> int:
	return current_level

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

func equip(skin_name: String) -> void:
	equipped_skin = skin_name
	emit_signal("skin_equipped", skin_name)

func get_bonus(stat: String) -> float:
	if equipped_skin == "":
		return 0.0
	var skin = _get_character(equipped_skin)
	if skin.is_empty() or not skin["bonus"].has(stat):
		return 0.0
	var entry = get_entry(equipped_skin)
	var level = entry.get("level", 1)
	return skin["bonus"][stat] * level

func _get_character(skin_name: String) -> Dictionary:
	for c in CHARACTERS:
		if c["name"] == skin_name:
			return c
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
