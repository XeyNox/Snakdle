extends Control

@onready var hp_bar: ProgressBar = $HPBar
@onready var boss_label: Label = $BossLabel
@onready var reward_label: Label = $RewardLabel

func _ready() -> void:
	GameManager.on_boss_page = true
	GameManager.boss_started.connect(_on_boss_started)
	GameManager.boss_hp_changed.connect(_on_hp_changed)
	GameManager.boss_defeated.connect(_on_boss_defeated)

	# Si un boss est déjà actif au moment où cette UI apparaît
	# (ex: scène recréée en cours de partie), on se resynchronise
	# tout de suite au lieu d'attendre le prochain signal.
	if GameManager.boss_active:
		_on_boss_started(GameManager.boss_max_hp)
		_on_hp_changed(GameManager.boss_hp, GameManager.boss_max_hp)
	else:
		hide()

func _exit_tree() -> void:
	GameManager.on_boss_page = false

func _process(_delta: float) -> void:
	if GameManager.player_hp <= 0.0:
		GameManager.screen_state = "gameover"
		GameManager.player_died.emit()
		get_tree().change_scene_to_file("res://Scenes/TitleScreen.tscn")

func _on_boss_started(max_hp: float) -> void:
	hp_bar.max_value = max_hp
	hp_bar.value = max_hp
	boss_label.text = "BOSS — Niveau %d" % GameManager.boss_level
	show()

func _on_hp_changed(hp: float, _max_hp: float) -> void:
	hp_bar.value = hp

func _on_boss_defeated(gems: int) -> void:
	reward_label.text = "+%d gems !" % gems
	await get_tree().create_timer(1.5).timeout
	if not GameManager.boss_active:
		hide()
	reward_label.text = ""
