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
	master_value_label.text = str(int(db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index(&"Master")))) * 100)
	music_value_label.text = str(int(db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index(&"Music"))))* 100)
	sfx_value_label.text = str(int(db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index(&"SFX")))) * 100)
	ambient_value_label.text = str(int(db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index(&"SFXAmbient"))))* 100)

	master_slider.value = ((db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index(&"Master"))))) * 100
	master_slider.value = ((db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index(&"Music"))))) * 100
	master_slider.value = ((db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index(&"SFX"))))) * 100
	master_slider.value = ((db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index(&"SFXAmbient"))))) * 100

	master_slider.value_changed.connect(on_slider_value_changed.bind(master_value_label, SoundEffect.Bus.MASTER))
	music_slider.value_changed.connect(on_slider_value_changed.bind(music_value_label, SoundEffect.Bus.MUSIC))
	sfx_slider.value_changed.connect(on_slider_value_changed.bind(sfx_value_label, SoundEffect.Bus.SFX))
	ambient_slider.value_changed.connect(on_slider_value_changed.bind(ambient_value_label, SoundEffect.Bus.SFX_AMBIENT))

	# print(AudioServer.get_bus_volume_db(AudioServer.get_bus_index(&"Master")))

func on_slider_value_changed(_value: float, _slider_value_label: Label, _bus: SoundEffect.Bus) -> void:
	
	_value /= 100
	# print(_value)
	_slider_value_label.text = str(int(_value * 100))
	var bus_index: int = AudioServer.get_bus_index(AudioManager.get_bus_string_name(_bus))
	var bus_value = linear_to_db(_value)
	# print(bus_value)
	
	AudioServer.set_bus_volume_db(bus_index, bus_value)
	# AudioServer.set_bus_mute(bus_index, bus_value <= 0)
