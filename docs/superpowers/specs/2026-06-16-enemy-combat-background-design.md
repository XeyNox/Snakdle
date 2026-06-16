# Enemy Combat Background — Design Spec
Date: 2026-06-16

## Overview

Add automatic idle combat to the background of the main scene. Enemies spawn randomly from the sides of the screen, walk toward the player's Snake, fight automatically, and drop a random stat boost (attack or defense) on death. The system pauses when a boss is active and resumes after the boss is defeated.

## Architecture

### New files
| File | Role |
|---|---|
| `Scripts/enemy.gd` | Individual enemy: movement, HP, attack timer, death + stat drop |
| `Scenes/Enemy.tscn` | Enemy scene — Label root with enemy.gd, colored rectangle placeholder |
| `Scripts/enemy_manager.gd` | Spawning, focus-fire, pause/resume on boss events |

### Modified files
| File | Change |
|---|---|
| `Scenes/background.tscn` | Add EnemyManager node (Node2D) as child of Background |
| `Scripts/game_scene.gd` | Call EnemyManager.pause_spawning / resume_spawning on boss signals |

## Enemy Behavior (`enemy.gd`)

- **HP**: `30 + GameManager.boss_level * 10`
- **Attack**: `5 + GameManager.boss_level * 2` damage every 3 seconds to `GameManager.player_hp`
- **Speed**: moves horizontally from spawn side toward Snake (x≈200), y≈450
- **States**: `moving` → walks until within 100px of Snake, then `fighting` → attacks on timer
- **Death**: emits `died` signal, then randomly adds `+0.5` to `player_attack` OR `+0.3` to `player_defense`
- **Visual**: colored rectangle placeholder (red) until real sprites are added

## EnemyManager (`enemy_manager.gd`)

- `max_enemies = 3`
- Spawn timer: random 3.0–7.0 seconds, random side (left x=-50 or right x=viewport_width+50), y≈450
- Only spawns if `enemy_count < max_enemies` AND NOT paused
- `_process(delta)`: applies `GameManager.player_attack * delta` damage to the first living enemy (focus fire)
- `pause_spawning()`: clears all active enemies, stops timer
- `resume_spawning()`: restarts spawn timer

## Integration

- `game_scene.gd._on_boss_started` → calls `$EnemyManager.pause_spawning()`
- `game_scene.gd._on_boss_defeated` → calls `$EnemyManager.resume_spawning()`
- `GameManager.gd`: no changes — enemies read/write `player_hp`, `player_attack`, `player_defense` directly

## Constraints

- Player character sprite is a placeholder for now — real sprite implemented later
- No new signals added to GameManager
- Enemy HP and attack scale with `boss_level` to stay relevant throughout progression
