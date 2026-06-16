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
