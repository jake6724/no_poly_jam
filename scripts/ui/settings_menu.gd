class_name SettingsMenu
extends Control

@export var master_slider: HSlider
@export var music_slider: HSlider
@export var sfx_slider: HSlider
@export var ambient_slider: HSlider

@export var master_value_label: Label
@export var music_value_label: Label
@export var sfx_value_label: Label
@export var ambient_value_label: Label

func _ready():
	master_value_label.text = str(int(master_slider.value))
	music_value_label.text = str(int(music_slider.value))
	sfx_value_label.text = str(int(sfx_slider.value))
	ambient_value_label.text = str(int(ambient_slider.value))

	master_slider.value_changed.connect(on_slider_value_changed.bind(master_value_label, SoundEffect.Bus.MASTER))
	music_slider.value_changed.connect(on_slider_value_changed.bind(music_value_label, SoundEffect.Bus.MUSIC))
	sfx_slider.value_changed.connect(on_slider_value_changed.bind(sfx_value_label, SoundEffect.Bus.SFX))
	ambient_slider.value_changed.connect(on_slider_value_changed.bind(ambient_value_label, SoundEffect.Bus.SFX_AMBIENT))

func on_slider_value_changed(_value: float, _slider_value_label: Label, _bus: SoundEffect.Bus) -> void:
	_slider_value_label.text = str(int(_value))
	var bus_index: int = AudioServer.get_bus_index(AudioManager.get_bus_string_name(_bus))
	var bus_value = linear_to_db(_value)
	AudioServer.set_bus_volume_db(bus_index, bus_value)
	AudioServer.set_bus_mute(bus_index, bus_value <= 0)
