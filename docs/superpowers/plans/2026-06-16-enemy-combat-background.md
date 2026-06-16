# Enemy Combat Background — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add automatic idle combat to the background — enemies spawn from the sides, walk toward the Snake, fight automatically, and drop a random stat boost on death.

**Architecture:** Three new files (`enemy.gd`, `Enemy.tscn`, `enemy_manager.gd`) + minor changes to `game_scene.gd` and `background.tscn`. EnemyManager lives as a child of Background in the scene tree and orchestrates spawning and focus-fire. Each Enemy node is self-contained.

**Tech Stack:** Godot 4, GDScript, GameManager autoload (existing singleton)

---

## File Map

| Action | Path | Responsibility |
|---|---|---|
| Create | `Scripts/enemy.gd` | Movement, HP, attack timer, stat drop on death |
| Create | `Scenes/Enemy.tscn` | Enemy scene — Node2D root + ColorRect placeholder |
| Create | `Scripts/enemy_manager.gd` | Spawning, focus-fire, pause/resume on boss events |
| Modify | `Scenes/background.tscn` | Add EnemyManager node as child of Background |
| Modify | `Scripts/game_scene.gd` | Call pause/resume on boss signals |

---

## Task 1: Créer `Scripts/enemy.gd`

**Files:**
- Create: `Scripts/enemy.gd`

- [ ] **Étape 1 : Créer le fichier `Scripts/enemy.gd` avec ce contenu**

```gdscript
extends Node2D

signal died

var hp: float = 0.0
var attack: float = 0.0
var target_x: float = 200.0

const SPEED := 80.0
const ATTACK_INTERVAL := 3.0
const ATTACK_RANGE := 100.0

var _attack_timer: float = 0.0

func setup() -> void:
    hp = 30.0 + GameManager.boss_level * 10.0
    attack = 5.0 + GameManager.boss_level * 2.0

func _process(delta: float) -> void:
    if GameManager.screen_state != "playing":
        return
    if abs(position.x - target_x) > ATTACK_RANGE:
        position.x += sign(target_x - position.x) * SPEED * delta
    else:
        _attack_timer += delta
        if _attack_timer >= ATTACK_INTERVAL:
            _attack_timer = 0.0
            _attack_player()

func take_damage(amount: float) -> void:
    hp -= amount
    if hp <= 0.0:
        _die()

func _attack_player() -> void:
    if randf() < GameManager.player_evasion:
        return
    var dmg := maxf(1.0, attack - GameManager.player_defense)
    GameManager.player_hp = maxf(0.0, GameManager.player_hp - dmg)
    GameManager.player_hp_changed.emit(GameManager.player_hp, GameManager.player_max_hp)
    if GameManager.player_hp <= 0.0:
        GameManager._player_die()

func _die() -> void:
    if randi() % 2 == 0:
        GameManager.player_attack += 0.5
    else:
        GameManager.player_defense += 0.3
    died.emit()
    queue_free()
```

> Note: `GameManager._player_die()` commence par `_` par convention, mais en GDScript ce n'est pas vraiment privé — l'appel fonctionne.

- [ ] **Étape 2 : Commit**

```bash
git add Scripts/enemy.gd
git commit -m "feat: add enemy.gd with movement, combat and stat drop"
```

---

## Task 2: Créer `Scenes/Enemy.tscn`

**Files:**
- Create: `Scenes/Enemy.tscn` (via l'éditeur Godot)

- [ ] **Étape 1 : Créer la scène dans l'éditeur Godot**

  1. Dans le panneau FileSystem, clic droit → **New Scene**
  2. Choisir **Node2D** comme nœud racine → renommer en `Enemy`
  3. Clic droit sur `Enemy` → **Attach Script** → sélectionner `res://Scripts/enemy.gd`
  4. Ajouter un enfant **ColorRect** au nœud `Enemy`
     - `Size` : `Vector2(40, 60)`
     - `Position` : `Vector2(-20, -60)` (centré/au-dessus du point d'origine)
     - `Color` : rouge `Color(0.8, 0.1, 0.1, 1)`
  5. Sauvegarder la scène sous `Scenes/Enemy.tscn`

- [ ] **Étape 2 : Commit**

```bash
git add Scenes/Enemy.tscn
git commit -m "feat: add Enemy.tscn placeholder scene"
```

---

## Task 3: Créer `Scripts/enemy_manager.gd`

**Files:**
- Create: `Scripts/enemy_manager.gd`

- [ ] **Étape 1 : Créer le fichier `Scripts/enemy_manager.gd` avec ce contenu**

```gdscript
extends Node2D

const EnemyScene = preload("res://Scenes/Enemy.tscn")
const MAX_ENEMIES := 3

var _enemies: Array = []
var _spawn_timer: float = 0.0
var _next_spawn_time: float = 0.0
var _paused: bool = false

func _ready() -> void:
    _reset_spawn_timer()

func _process(delta: float) -> void:
    if _paused or GameManager.screen_state != "playing":
        return

    if _enemies.size() > 0 and is_instance_valid(_enemies[0]):
        _enemies[0].take_damage(GameManager.player_attack * delta)

    _spawn_timer += delta
    if _spawn_timer >= _next_spawn_time and _enemies.size() < MAX_ENEMIES:
        _spawn_enemy()
        _reset_spawn_timer()

func pause_spawning() -> void:
    _paused = true
    for enemy in _enemies:
        if is_instance_valid(enemy):
            enemy.queue_free()
    _enemies.clear()

func resume_spawning() -> void:
    _paused = false
    _reset_spawn_timer()

func _spawn_enemy() -> void:
    var enemy = EnemyScene.instantiate()
    var vp_width: float = get_viewport_rect().size.x
    if randi() % 2 == 0:
        enemy.position = Vector2(-50.0, 450.0)
    else:
        enemy.position = Vector2(vp_width + 50.0, 450.0)
    enemy.setup()
    enemy.died.connect(_on_enemy_died.bind(enemy))
    add_child(enemy)
    _enemies.append(enemy)

func _on_enemy_died(enemy: Node2D) -> void:
    _enemies.erase(enemy)

func _reset_spawn_timer() -> void:
    _spawn_timer = 0.0
    _next_spawn_time = randf_range(3.0, 7.0)
```

> Les ennemis des deux côtés convergent vers le Snake (`target_x = 200.0` par défaut). Un ennemi venant de la droite se déplace donc vers la gauche jusqu'à être à portée du Snake.

- [ ] **Étape 2 : Commit**

```bash
git add Scripts/enemy_manager.gd
git commit -m "feat: add enemy_manager.gd with spawning and focus-fire"
```

---

## Task 4: Modifier `Scenes/background.tscn`

**Files:**
- Modify: `Scenes/background.tscn` (via l'éditeur Godot)

- [ ] **Étape 1 : Ajouter le nœud EnemyManager dans l'éditeur Godot**

  1. Ouvrir `Scenes/background.tscn`
  2. Dans le panneau Scene, sélectionner le nœud racine `Background`
  3. Ajouter un enfant **Node2D** → renommer en `EnemyManager`
  4. Clic droit sur `EnemyManager` → **Attach Script** → sélectionner `res://Scripts/enemy_manager.gd`
  5. Sauvegarder la scène (`Ctrl+S`)

- [ ] **Étape 2 : Commit**

```bash
git add Scenes/background.tscn
git commit -m "feat: add EnemyManager node to background scene"
```

---

## Task 5: Modifier `Scripts/game_scene.gd`

**Files:**
- Modify: `Scripts/game_scene.gd`

Le fichier actuel (`game_scene.gd`) ne connaît pas encore l'EnemyManager. Il faut l'ajouter.

- [ ] **Étape 1 : Mettre à jour `Scripts/game_scene.gd`**

Remplacer le contenu entier par :

```gdscript
extends Node2D

@onready var snake: AnimatedSprite2D = $Snake
@onready var boss: AnimatedSprite2D = $Boss
@onready var enemy_manager = $EnemyManager

func _ready() -> void:
    GameManager.boss_started.connect(_on_boss_started)
    GameManager.boss_defeated.connect(_on_boss_defeated)
    GameManager.player_died.connect(_on_player_died)
    boss.visible = false
    _play(snake, "walk")

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_cancel") and GameManager.screen_state == "playing":
        GameManager.screen_state = "pause"
        get_tree().change_scene_to_file("res://Scenes/TitleScreen.tscn")

func _on_boss_started(_max_hp: float) -> void:
    boss.visible = true
    _play(snake, "attack")
    _play(boss, "idle")
    enemy_manager.pause_spawning()

func _on_boss_defeated(_gems: int) -> void:
    _play(boss, "death")
    await get_tree().create_timer(1.0).timeout
    boss.visible = false
    _play(snake, "walk")
    enemy_manager.resume_spawning()

func _on_player_died() -> void:
    _play(snake, "hurt")
    await get_tree().create_timer(1.0).timeout
    if is_instance_valid(self):
        get_tree().change_scene_to_file("res://Scenes/TitleScreen.tscn")

func _play(sprite: AnimatedSprite2D, anim: String) -> void:
    if sprite.sprite_frames != null and sprite.sprite_frames.has_animation(anim):
        sprite.play(anim)
```

- [ ] **Étape 2 : Commit**

```bash
git add Scripts/game_scene.gd
git commit -m "feat: connect EnemyManager pause/resume to boss signals"
```

---

## Task 6: Vérifier en jeu

- [ ] **Étape 1 : Lancer le jeu** (`F5` dans Godot)

- [ ] **Étape 2 : Vérifier les comportements suivants**

  | Comportement | Attendu |
  |---|---|
  | Après 3-7 secondes | Un ennemi rouge apparaît d'un côté |
  | L'ennemi | Se déplace vers le Snake |
  | Arrivé près du Snake | S'arrête et attaque toutes les 3 secondes |
  | `player_hp` | Diminue progressivement (visible dans l'UI) |
  | L'ennemi | Perd des HP automatiquement (focus-fire) |
  | Quand l'ennemi meurt | Un nouveau peut spawner ; stats joueur +0.5 attack ou +0.3 defense |
  | Max 3 ennemis | Jamais plus de 3 rectangles rouges simultanément |
  | Quand boss actif | Tous les ennemis disparaissent |
  | Quand boss vaincu | Les ennemis recommencent à spawner |

- [ ] **Étape 3 : Commit final**

```bash
git add .
git commit -m "feat: enemy combat background system complete"
```
