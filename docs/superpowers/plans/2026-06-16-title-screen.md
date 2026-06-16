# Title Screen Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ajouter un écran d'accueil Snakdle avec bouton Jouer, panneau paramètres (volume musique/sons) et serpent animé en fond ; gérer les états pause (Échap) et game over (mort par boss).

**Architecture:** `TitleScreen.tscn` devient la scène d'entrée. `GameManager` (autoload singleton existant) gagne `screen_state`, `music_volume`, `sfx_volume` et `reset_game()` — ces données survivent aux changements de scène. La touche Échap et la mort du boss déclenchent un retour vers TitleScreen avec l'état approprié.

**Tech Stack:** Godot 4.6, GDScript

---

## Fichiers créés / modifiés

| Action | Fichier | Rôle |
|--------|---------|------|
| Modifier | `Scripts/GameManager.gd` | Ajouter state, volumes, reset_game(), modifier _player_die() |
| Modifier | `Scripts/game_scene.gd` | Ajouter gestion Échap et transition scene morte |
| Créer | `Scripts/settings_panel.gd` | Logique sliders volume |
| Créer | `Scripts/title_screen.gd` | Logique écran titre (états, boutons) |
| Créer | `Scenes/TitleScreen.tscn` | Scène écran titre |
| Modifier | `project.godot` | Changer la scène principale |

---

## Task 1 : Étendre GameManager

**Fichiers :**
- Modifier : `Scripts/GameManager.gd`

- [ ] **Étape 1 : Ajouter les variables et reset_game()**

Dans `Scripts/GameManager.gd`, ajouter ces variables après les variables existantes (après la ligne `var _damage_timer`) :

```gdscript
var screen_state: String = "start"
var music_volume: float = 1.0
var sfx_volume: float = 1.0
```

Ajouter cette fonction après `buy_evasion_upgrade()` :

```gdscript
func reset_game() -> void:
	money = 0.0
	money_per_second = 1.0
	money_per_click = 1.0
	idle_upgrade_cost = 10.0
	click_upgrade_cost = 10.0
	player_hp = 100.0
	player_max_hp = 100.0
	player_attack = 10.0
	player_defense = 5.0
	player_evasion = 0.1
	hp_upgrade_cost = 25.0
	attack_upgrade_cost = 25.0
	defense_upgrade_cost = 25.0
	evasion_upgrade_cost = 40.0
	boss_level = 1
	boss_hp = 0.0
	boss_max_hp = 0.0
	boss_active = false
	_damage_timer = 0.0
```

- [ ] **Étape 2 : Modifier `_process` pour stopper quand game over**

Remplacer la première ligne de `_process` pour ajouter un guard :

```gdscript
func _process(delta: float) -> void:
	if screen_state == "gameover":
		return
	money += money_per_second * delta
	# ... reste inchangé
```

- [ ] **Étape 3 : Modifier `_player_die()`**

Remplacer la fonction `_player_die()` entière :

```gdscript
func _player_die() -> void:
	screen_state = "gameover"
	player_died.emit()
```

(La remise à zéro de HP/boss se fait dans `reset_game()` au clic "Rejouer". Le changement de scène se fait dans `game_scene.gd` après l'animation.)

- [ ] **Étape 4 : Vérifier**

Ouvrir le projet dans Godot, onglet Output → aucune erreur de parsing sur GameManager.gd.

- [ ] **Étape 5 : Commit**

```bash
git add Scripts/GameManager.gd
git commit -m "feat: add screen_state, volumes, reset_game and gameover state to GameManager"
```

---

## Task 2 : Gérer Échap et mort dans game_scene.gd

**Fichiers :**
- Modifier : `Scripts/game_scene.gd`

- [ ] **Étape 1 : Remplacer le contenu complet de game_scene.gd**

```gdscript
extends Node2D

@onready var snake: AnimatedSprite2D = $Snake
@onready var boss: AnimatedSprite2D  = $Boss

func _ready() -> void:
	GameManager.boss_started.connect(_on_boss_started)
	GameManager.boss_defeated.connect(_on_boss_defeated)
	GameManager.player_died.connect(_on_player_died)
	boss.visible = false
	_play(snake, "walk")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and GameManager.screen_state != "gameover":
		GameManager.screen_state = "pause"
		get_tree().change_scene_to_file("res://Scenes/TitleScreen.tscn")

func _on_boss_started(_max_hp: float) -> void:
	boss.visible = true
	_play(snake, "attack")
	_play(boss, "idle")

func _on_boss_defeated(_gems: int) -> void:
	_play(boss, "death")
	await get_tree().create_timer(1.0).timeout
	boss.visible = false
	_play(snake, "walk")

func _on_player_died() -> void:
	_play(snake, "hurt")
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://Scenes/TitleScreen.tscn")

func _play(sprite: AnimatedSprite2D, anim: String) -> void:
	if sprite.sprite_frames != null and sprite.sprite_frames.has_animation(anim):
		sprite.play(anim)
```

- [ ] **Étape 2 : Vérifier**

Lancer le jeu (encore depuis Main.tscn). Appuyer Échap → une erreur "scène non trouvée" dans la console est normale à ce stade (TitleScreen.tscn n'existe pas encore).

- [ ] **Étape 3 : Commit**

```bash
git add Scripts/game_scene.gd
git commit -m "feat: add Escape pause and post-death scene transition"
```

---

## Task 3 : Créer settings_panel.gd

**Fichiers :**
- Créer : `Scripts/settings_panel.gd`

- [ ] **Étape 1 : Créer le fichier**

```gdscript
extends PanelContainer

@onready var music_slider: HSlider = $VBoxContainer/MusicSlider
@onready var sound_slider: HSlider = $VBoxContainer/SoundSlider
@onready var close_button: Button  = $VBoxContainer/CloseButton

func _ready() -> void:
	music_slider.value = GameManager.music_volume
	sound_slider.value = GameManager.sfx_volume
	music_slider.value_changed.connect(_on_music_changed)
	sound_slider.value_changed.connect(_on_sound_changed)
	close_button.pressed.connect(hide)

func _on_music_changed(value: float) -> void:
	GameManager.music_volume = value
	var idx := AudioServer.get_bus_index("Music")
	if idx >= 0:
		AudioServer.set_bus_volume_db(idx, linear_to_db(maxf(value, 0.0001)))

func _on_sound_changed(value: float) -> void:
	GameManager.sfx_volume = value
	var idx := AudioServer.get_bus_index("SFX")
	if idx >= 0:
		AudioServer.set_bus_volume_db(idx, linear_to_db(maxf(value, 0.0001)))
```

Note : `get_bus_index` retourne -1 si le bus n'existe pas — le code ne crashe pas si les bus "Music"/"SFX" ne sont pas encore créés dans le projet.

- [ ] **Étape 2 : Commit**

```bash
git add Scripts/settings_panel.gd
git commit -m "feat: add settings panel script with safe audio volume controls"
```

---

## Task 4 : Créer title_screen.gd

**Fichiers :**
- Créer : `Scripts/title_screen.gd`

- [ ] **Étape 1 : Créer le fichier**

```gdscript
extends Node2D

@onready var subtitle_label:  Label          = $CanvasLayer/SubtitleLabel
@onready var play_button:     Button         = $CanvasLayer/PlayButton
@onready var settings_button: Button         = $CanvasLayer/SettingsButton
@onready var settings_panel:  PanelContainer = $CanvasLayer/SettingsPanel

func _ready() -> void:
	match GameManager.screen_state:
		"pause":
			subtitle_label.text = "En pause"
			subtitle_label.show()
			play_button.text = "Reprendre"
		"gameover":
			subtitle_label.text = "Game Over"
			subtitle_label.show()
			play_button.text = "Rejouer"
		_:
			subtitle_label.hide()
			play_button.text = "Jouer"

	play_button.pressed.connect(_on_play_pressed)
	settings_button.pressed.connect(_on_settings_pressed)

func _on_play_pressed() -> void:
	if GameManager.screen_state == "gameover":
		GameManager.reset_game()
	GameManager.screen_state = "start"
	get_tree().change_scene_to_file("res://Scenes/Main.tscn")

func _on_settings_pressed() -> void:
	settings_panel.visible = not settings_panel.visible
```

- [ ] **Étape 2 : Commit**

```bash
git add Scripts/title_screen.gd
git commit -m "feat: add title screen script with state-driven UI"
```

---

## Task 5 : Créer TitleScreen.tscn

**Fichiers :**
- Créer : `Scenes/TitleScreen.tscn`

- [ ] **Étape 1 : Créer le fichier de scène**

```
[gd_scene format=3 uid="uid://c5titlescren01"]

[ext_resource type="PackedScene" uid="uid://cge6os48vo14u" path="res://Scenes/background.tscn" id="1_bg"]
[ext_resource type="Script" path="res://Scripts/title_screen.gd" id="2_ts"]
[ext_resource type="Script" path="res://Scripts/settings_panel.gd" id="3_sp"]

[node name="TitleScreen" type="Node2D"]
script = ExtResource("2_ts")

[node name="BackgroundLayer" type="CanvasLayer" parent="."]
layer = -1

[node name="Background" parent="BackgroundLayer" instance=ExtResource("1_bg")]

[node name="CanvasLayer" type="CanvasLayer" parent="."]

[node name="TitleLabel" type="Label" parent="CanvasLayer"]
anchors_preset = -1
anchor_left = 0.5
anchor_right = 0.5
anchor_top = 0.0
anchor_bottom = 0.0
offset_left = -150.0
offset_top = 60.0
offset_right = 150.0
offset_bottom = 130.0
grow_horizontal = 2
text = "Snakdle"
horizontal_alignment = 1
theme_override_font_sizes/font_size = 64

[node name="SubtitleLabel" type="Label" parent="CanvasLayer"]
anchors_preset = -1
anchor_left = 0.5
anchor_right = 0.5
anchor_top = 0.0
anchor_bottom = 0.0
offset_left = -150.0
offset_top = 145.0
offset_right = 150.0
offset_bottom = 185.0
grow_horizontal = 2
text = ""
horizontal_alignment = 1
theme_override_font_sizes/font_size = 28

[node name="PlayButton" type="Button" parent="CanvasLayer"]
custom_minimum_size = Vector2(200, 60)
anchors_preset = 8
anchor_left = 0.5
anchor_top = 0.5
anchor_right = 0.5
anchor_bottom = 0.5
offset_left = -100.0
offset_top = -30.0
offset_right = 100.0
offset_bottom = 30.0
grow_horizontal = 2
grow_vertical = 2
text = "Jouer"

[node name="SettingsButton" type="Button" parent="CanvasLayer"]
custom_minimum_size = Vector2(150, 45)
anchors_preset = -1
anchor_left = 0.0
anchor_right = 0.0
anchor_top = 1.0
anchor_bottom = 1.0
offset_left = 20.0
offset_top = -65.0
offset_right = 170.0
offset_bottom = -20.0
text = "Paramètres"

[node name="SettingsPanel" type="PanelContainer" parent="CanvasLayer"]
anchors_preset = 8
anchor_left = 0.5
anchor_top = 0.5
anchor_right = 0.5
anchor_bottom = 0.5
offset_left = -160.0
offset_top = -135.0
offset_right = 160.0
offset_bottom = 135.0
grow_horizontal = 2
grow_vertical = 2
visible = false
script = ExtResource("3_sp")

[node name="VBoxContainer" type="VBoxContainer" parent="CanvasLayer/SettingsPanel"]
layout_mode = 2

[node name="MusicLabel" type="Label" parent="CanvasLayer/SettingsPanel/VBoxContainer"]
layout_mode = 2
text = "Volume musique"

[node name="MusicSlider" type="HSlider" parent="CanvasLayer/SettingsPanel/VBoxContainer"]
layout_mode = 2
custom_minimum_size = Vector2(280, 30)
max_value = 1.0
step = 0.01
value = 1.0

[node name="SoundLabel" type="Label" parent="CanvasLayer/SettingsPanel/VBoxContainer"]
layout_mode = 2
text = "Volume sons"

[node name="SoundSlider" type="HSlider" parent="CanvasLayer/SettingsPanel/VBoxContainer"]
layout_mode = 2
custom_minimum_size = Vector2(280, 30)
max_value = 1.0
step = 0.01
value = 1.0

[node name="CloseButton" type="Button" parent="CanvasLayer/SettingsPanel/VBoxContainer"]
layout_mode = 2
text = "Fermer"
```

- [ ] **Étape 2 : Vérifier dans l'éditeur Godot**

Ouvrir `Scenes/TitleScreen.tscn`. La scène doit afficher le décor de fond avec le serpent, le label "Snakdle" en haut, le bouton "Jouer" au centre, le bouton "Paramètres" en bas à gauche. Aucune erreur dans Output.

- [ ] **Étape 3 : Commit**

```bash
git add Scenes/TitleScreen.tscn
git commit -m "feat: create TitleScreen scene with background, title, play and settings buttons"
```

---

## Task 6 : Définir TitleScreen comme scène principale

**Fichiers :**
- Modifier : `project.godot`

- [ ] **Étape 1 : Changer `run/main_scene`**

Dans `project.godot`, remplacer :
```
run/main_scene="uid://b4o480kiumhhj"
```
par :
```
run/main_scene="res://Scenes/TitleScreen.tscn"
```

- [ ] **Étape 2 : Test — Premier lancement**

Appuyer sur F5. Résultat attendu :
- Décor (ciel, collines, fleurs) visible en fond
- Serpent qui marche de gauche à droite
- "Snakdle" en grand en haut
- Bouton "Jouer" au centre
- Bouton "Paramètres" en bas à gauche
- Aucun sous-titre visible

- [ ] **Étape 3 : Commit**

```bash
git add project.godot
git commit -m "feat: set TitleScreen as startup scene"
```

---

## Task 7 : Tests d'intégration

- [ ] **Test 1 — Jouer**

Depuis l'écran titre, cliquer "Jouer" → `Main.tscn` se charge, le jeu démarre normalement (argent à 0, stats initiales).

- [ ] **Test 2 — Paramètres**

Cliquer "Paramètres" → panneau apparaît avec "Volume musique" + slider, "Volume sons" + slider, bouton "Fermer". Déplacer un slider → valeur change. Cliquer "Fermer" → panneau se cache. Recliquer "Paramètres" → slider est à la valeur précédente.

- [ ] **Test 3 — Pause (Échap)**

En jeu : accumuler quelques $ et acheter un upgrade. Appuyer Échap → retour à l'écran titre. "En pause" apparaît sous "Snakdle", bouton dit "Reprendre". Cliquer "Reprendre" → retour au jeu, l'argent et les upgrades achetés sont préservés.

- [ ] **Test 4 — Game Over**

En jeu : atteindre le boss (50$) et ne pas tuer le boss avant qu'il tue le joueur (attendre ~15 secondes sans élever les stats). 1 seconde après la mort → écran titre. "Game Over" sous "Snakdle", bouton dit "Rejouer". Cliquer "Rejouer" → jeu repart de zéro (money=0, money_per_click=1.0, boss_level=1).

- [ ] **Test 5 — Pas de double-transition**

Se faire tuer. Pendant la seconde d'animation, appuyer Échap → rien ne se passe (le guard `screen_state != "gameover"` bloque). L'écran Game Over apparaît normalement.

- [ ] **Commit final**

```bash
git add -A
git commit -m "feat: complete title screen with start, pause, and game over states"
```
