# Design — Écran d'accueil (Title Screen)

Date : 2026-06-16

## Contexte

Snakdle est un jeu idle/clicker en Godot 4. La scène de jeu principale (`Main.tscn`) se lance directement sans écran d'accueil. L'objectif est d'ajouter un écran titre avec serpent animé, bouton Jouer, et un panneau paramètres (volume musique/sons).

---

## Architecture

### Nouveaux fichiers

| Fichier | Rôle |
|---------|------|
| `Scenes/TitleScreen.tscn` | Nouvelle scène principale (remplace Main.tscn dans project.godot) |
| `Scripts/title_screen.gd` | Logique de l'écran titre (états, boutons, transition) |
| `Scripts/settings_panel.gd` | Logique du panneau paramètres (sliders audio) |

### Fichiers modifiés

| Fichier | Modification |
|---------|-------------|
| `project.godot` | `run/main_scene` pointe vers `TitleScreen.tscn` |
| `Scripts/GameManager.gd` | Ajout de `screen_state`, `music_volume`, `sfx_volume`, et `reset_game()` ; modification de `_player_die()` pour déclencher le retour au titre |
| `Scripts/game_scene.gd` | Ajout de la gestion de la touche Échap (appel `_go_to_title("pause")`) |

---

## États & transitions

`GameManager.screen_state: String` prend trois valeurs :

| Valeur | Contexte | Titre affiché | Bouton principal | Sous-titre |
|--------|----------|--------------|-----------------|------------|
| `"start"` | Premier lancement | Snakdle | Jouer | _(aucun)_ |
| `"pause"` | Échap en jeu | Snakdle | Reprendre | En pause |
| `"gameover"` | Mort par le boss | Snakdle | Rejouer | Game Over |

### Flux de navigation

```
[Lancement] → TitleScreen (screen_state = "start")
    Jouer       → change_scene → Main.tscn
    Échap       → screen_state = "pause" → change_scene → TitleScreen
    Mort boss   → screen_state = "gameover" → change_scene → TitleScreen
    Rejouer     → reset_game() → change_scene → Main.tscn
```

`reset_game()` remet à zéro toutes les variables de jeu (money, stats, boss_level, etc.) sans toucher à `screen_state`, `music_volume`, ni `sfx_volume`.

La fonction `_player_die()` dans `GameManager.gd` est modifiée : au lieu de soigner le joueur sur place, elle set `screen_state = "gameover"` et appelle `get_tree().change_scene_to_file("res://Scenes/TitleScreen.tscn")`. La remise à zéro se fait au clic "Rejouer" (pas à la mort), ce qui permet d'afficher les stats finales sur l'écran titre si désiré à l'avenir.

---

## Layout de TitleScreen.tscn

```
TitleScreen (Node2D)
├── BackgroundLayer (CanvasLayer, layer = -1)
│   └── Background (instance de background.tscn)   ← même décor + serpent animé
└── CanvasLayer (layer = 1)
    ├── TitleLabel       ← "Snakdle", grand, centré en haut
    ├── SubtitleLabel    ← "Game Over" / "En pause", centré sous le titre (caché si "start")
    ├── PlayButton       ← "Jouer" / "Reprendre" / "Rejouer", centré verticalement
    ├── SettingsButton   ← "Paramètres", coin bas-droite
    └── SettingsPanel    ← panneau caché par défaut
        ├── Label "Volume musique"
        ├── MusicSlider  ← HSlider 0.0–1.0
        ├── Label "Volume sons"
        ├── SoundSlider  ← HSlider 0.0–1.0
        └── CloseButton  ← ferme le panneau
```

Le nœud `Snake` dans `background.tscn` joue déjà l'animation `walk` en continu — aucune modification nécessaire pour l'animation sur l'écran titre.

---

## Panneau paramètres

- Deux bus audio à créer dans le projet Godot : `"Music"` et `"SFX"`
- Chaque slider modifie `AudioServer.set_bus_volume_db(bus, linear_to_db(value))`
- Les valeurs sont stockées dans `GameManager.music_volume` et `GameManager.sfx_volume` (persistantes entre scènes)
- À l'ouverture du panneau : les sliders sont initialisés depuis les valeurs de GameManager
- Le panneau s'affiche/se cache via `show()` / `hide()` (pas de changement de scène)
- Les sliders sont fonctionnels dès maintenant, mais silencieux tant qu'aucun son/musique n'est ajouté au projet

---

## Variables ajoutées à GameManager

```gdscript
var screen_state: String = "start"
var music_volume: float = 1.0
var sfx_volume: float = 1.0

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
