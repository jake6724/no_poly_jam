extends Node3D
## Audio manager node. Inteded to be globally loaded as a 2D Scene. Handles [method create_2d_audio_at_location()] and 
## [method create_audio()] to handle the playback and culling of simultaneous sound effects.
## To properly use, define [enum SoundEffect.SOUND_EFFECT_TYPE] for each unique sound effect, 
## create a Node2D scene for this AudioManager script add those SoundEffect resources to this globally loaded script's [member sound_effects], 
## and setup your individual SoundEffect resources. Then, use [method create_2d_audio_at_location()] and [method create_audio()]
## to play those sound effects either at a specific location or globally.

var sound_effect_dict: Dictionary[SoundEffect.SOUND_EFFECT_TYPE, SoundEffect] = {} ## Loads all registered SoundEffects on ready as a reference.
var sound_effect_previous_sound_dict: Dictionary[SoundEffect, AudioStreamMP3] = {} ## Tracks the last played sound for each SoundEffect
var sound_effect_sequence_index_dict: Dictionary[SoundEffect, int]

@export var sound_effects: Array[SoundEffect] ## Stores all possible SoundEffects that can be played.
var music_player: AudioStreamPlayer = AudioStreamPlayer.new()
var current_music_track_volume_db: float 

var bus_mapping: Dictionary[SoundEffect.Bus, StringName] = {
	SoundEffect.Bus.MASTER: &"Master",
	SoundEffect.Bus.MUSIC: &"Music",
	SoundEffect.Bus.SFX: &"SFX",
	SoundEffect.Bus.SFX_AMBIENT: &"SFXAmbient",
}

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for sound_effect: SoundEffect in sound_effects:
		sound_effect_dict[sound_effect.type] = sound_effect
		sound_effect_sequence_index_dict[sound_effect] = 0

	add_child(music_player)
	set_music_track(SoundEffect.SOUND_EFFECT_TYPE.MUSIC_MAIN)


## Creates a sound effect at a specific location if the limit has not been reached. Pass [param location] for the global position of the audio effect, and [param type] for the SoundEffect to be queued.
func create_3d_audio_at_location(location: Vector3, type: SoundEffect.SOUND_EFFECT_TYPE) -> void:
	if sound_effect_dict.has(type):
		var sound_effect: SoundEffect = sound_effect_dict[type]
		if sound_effect.has_open_limit():
			var selected_sound: AudioStreamMP3 = select_sound(sound_effect)
			sound_effect.change_audio_count(1)
			var new_3D_audio: AudioStreamPlayer3D = AudioStreamPlayer3D.new()
			add_child(new_3D_audio)
			new_3D_audio.position = location
			new_3D_audio.stream = selected_sound
			new_3D_audio.volume_db = sound_effect.volume
			new_3D_audio.pitch_scale = sound_effect.pitch_scale
			new_3D_audio.pitch_scale += rng.randf_range(-sound_effect.pitch_randomness, sound_effect.pitch_randomness )
			new_3D_audio.max_distance = sound_effect.max_distance
			new_3D_audio.finished.connect(sound_effect.on_audio_finished)
			new_3D_audio.finished.connect(new_3D_audio.queue_free)
			new_3D_audio.bus = get_bus_string_name(sound_effect.bus)
			new_3D_audio.play()
	else:
		push_error("Audio Manager failed to find setting for type ", type)

## Creates a sound effect if the limit has not been reached. Pass [param type] for the SoundEffect to be queued.
func create_audio(type: SoundEffect.SOUND_EFFECT_TYPE) -> void:
	if sound_effect_dict.has(type):
		var sound_effect: SoundEffect = sound_effect_dict[type]
		if sound_effect.has_open_limit():
			var selected_sound: AudioStreamMP3 = select_sound(sound_effect)
			sound_effect.change_audio_count(1)
			var new_audio: AudioStreamPlayer = AudioStreamPlayer.new()
			add_child(new_audio)
			new_audio.stream = selected_sound
			new_audio.volume_db = sound_effect.volume
			new_audio.pitch_scale = sound_effect.pitch_scale
			new_audio.pitch_scale += rng.randf_range(-sound_effect.pitch_randomness, sound_effect.pitch_randomness )
			new_audio.finished.connect(sound_effect.on_audio_finished)
			new_audio.finished.connect(new_audio.queue_free)
			new_audio.bus = get_bus_string_name(sound_effect.bus)
			new_audio.play()
	else:
		push_error("Audio Manager failed to find setting for type ", type)

func select_sound(sound_effect: SoundEffect) -> AudioStreamMP3:
	var selected_sound: AudioStreamMP3
	if sound_effect.sounds.size() == 1:
		selected_sound = sound_effect.sounds[0]
	else:
		match sound_effect.select_mode:
			sound_effect.SelectMode.SEQUENTIAL:
				if sound_effect_sequence_index_dict[sound_effect] < sound_effect.sounds.size():
					selected_sound = sound_effect.sounds[sound_effect_sequence_index_dict[sound_effect]]
					sound_effect_sequence_index_dict[sound_effect] += 1
				else:
					sound_effect_sequence_index_dict[sound_effect] = 0
					selected_sound = sound_effect.sounds[sound_effect_sequence_index_dict[sound_effect]]
					sound_effect_sequence_index_dict[sound_effect] += 1

			sound_effect.SelectMode.RANDOM: # TODO: Look into optimizing?
				var prev: AudioStreamMP3 = sound_effect_previous_sound_dict.get(sound_effect, null)
				if prev:
					var sound_options: Array[AudioStreamMP3] = sound_effect.sounds.duplicate()
					sound_options.erase(prev)
					selected_sound = sound_options.pick_random()
				else:
					selected_sound = sound_effect.sounds.pick_random()

			sound_effect.SelectMode.TRUE_RANDOM:
				selected_sound = sound_effect.sounds.pick_random()

	sound_effect_previous_sound_dict[sound_effect] = selected_sound
	return selected_sound

func get_bus_string_name(_bus: SoundEffect.Bus) -> StringName:
	return bus_mapping[_bus]

func set_music_track(type: SoundEffect.SOUND_EFFECT_TYPE) -> void:
	if sound_effect_dict.has(type):
		var sound_effect: SoundEffect = sound_effect_dict[type]
		# if sound_effect.has_open_limit():
		var selected_sound: AudioStreamMP3 = select_sound(sound_effect)
		sound_effect.change_audio_count(1)
		music_player.stream = selected_sound
		music_player.volume_db = sound_effect.volume
		current_music_track_volume_db = sound_effect.volume
		music_player.pitch_scale = sound_effect.pitch_scale
		music_player.pitch_scale += rng.randf_range(-sound_effect.pitch_randomness, sound_effect.pitch_randomness )
		# music_player.finished.connect(sound_effect.on_audio_finished)
		music_player.bus = get_bus_string_name(sound_effect.bus)
		music_player.play()
	else:
		push_error("Audio Manager failed to find setting for type ", type)

func change_music_track(new_track: SoundEffect.SOUND_EFFECT_TYPE) -> void:
	var volume_down_tween: Tween = get_tree().create_tween()
	volume_down_tween.tween_property(music_player, "volume_db", -60, 2)
	await volume_down_tween.finished

	set_music_track(new_track)

	var volume_up_tween: Tween = get_tree().create_tween()
	volume_up_tween.tween_property(music_player, "volume_db", current_music_track_volume_db, 1).from(-80)

# func fade_in_music_player(fade_time: float=1.5) -> void:
# 	var volume_tween: Tween = get_tree().create_tween()
# 	volume_tween.tween_property(music_player, "volume_db", current_music_track_volume_db, fade_time)
# 	await volume_tween.finished

# func fade_out_music_player(fade_time: float=1.5) -> void:
# 	var volume_tween: Tween = get_tree().create_tween()
# 	volume_tween.tween_property(music_player, "volume_db", 0, fade_time)
# 	await volume_tween.finished