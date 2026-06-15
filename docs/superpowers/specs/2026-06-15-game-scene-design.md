# Game Scene Animée — Design

## Objectif
Remplacer le background statique par une scène de jeu vivante : le serpent se déplace et combat le boss, piloté par les signals existants de `GameManager`.

## Architecture

`background.tscn` devient la scène de jeu. Le fond cartoon reste via un nœud `Fond` enfant.

```
background.tscn
└── Node2D (game_scene.gd)
    ├── Fond (Node2D, background.gd)   ← fond cartoon inchangé
    ├── Snake (AnimatedSprite2D)        ← animations : walk, attack, hurt
    └── Boss (AnimatedSprite2D)         ← animations : idle, death — caché par défaut
```

## États

| Signal GameManager | Serpent       | Boss               |
|--------------------|---------------|--------------------|
| démarrage          | `walk`        | caché              |
| `boss_started`     | `attack`      | visible + `idle`   |
| `boss_defeated`    | `walk`        | `death` → caché    |
| `player_died`      | `hurt` → `walk` | reste visible    |

## Fichiers

| Fichier | Action |
|---|---|
| `Scripts/game_scene.gd` | Nouveau — gère les états |
| `Scenes/background.tscn` | Restructuré — nouveau nœud racine + Snake + Boss |
| `Scripts/background.gd` | Inchangé |
| `Main.tscn` | Aucun changement |
| `GameManager.gd` | Aucun changement |

## Notes
- `_play()` vérifie l'existence de l'animation avant de jouer → pas de crash si textures absentes
- Positions initiales : Snake (200, 450), Boss (900, 420) — ajustables dans l'éditeur
- Les textures et frames sont ajoutées manuellement par le développeur
