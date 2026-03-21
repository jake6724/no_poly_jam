class_name SoundEffect 
extends Resource
## Sound effect resource, used to configure unique sound effects for use with the AudioManager. Passed to [method AudioManager.create_2d_audio_at_location()] and [method AudioManager.create_audio()] to play sound effects.

## Stores the different types of sounds effects available to be played to distinguish them from another. Each new SoundEffect resource created should add to this enum, to allow them to be easily instantiated via [method AudioManager.create_2d_audio_at_location()] and [method AudioManager.create_audio()].
enum SOUND_EFFECT_TYPE {
    ABANDONED_MALL_AMBIENCE,
	BITE,
	FOOTSTEP,
	ZOMBIE_HIT,
	ZOMBIE_NOISE,
	MUSIC_MAIN,
	MUSIC_LOBBY,
	GHOST_SPAWN,
	PURCHASE,
	PICKUP
}

enum Bus {
	MASTER,
	MUSIC,
	SFX, 
	SFX_AMBIENT,
}

enum SelectMode {
	SEQUENTIAL,
	RANDOM,
	TRUE_RANDOM,
}

@export_range(0, 20) var limit: int = 5 ## Maximum number of this SoundEffect to play simultaneously before culled.
@export var type: SOUND_EFFECT_TYPE ## The unique sound effect in the [enum SOUND_EFFECT_TYPE] to associate with this effect. Each SoundEffect resource should have it's own unique [enum SOUND_EFFECT_TYPE] setting.
@export var sounds: Array[AudioStreamMP3] ## A list of possible [AudioStreamMP3] audio resources to play for this sound effect.
@export_range(-40, 20) var volume: float = 0 ## The volume of the [member sound_effect].
@export_range(0.0, 4.0,.01) var pitch_scale: float = 1.0 ## The pitch scale of the [member sound_effect].
@export_range(0.0, 1.0,.01) var pitch_randomness: float = 0.0 ## The pitch randomness setting of the [member sound_effect].
@export var select_mode: SelectMode = SelectMode.RANDOM
@export var max_distance: float = 700
@export var bus: Bus = Bus.SFX

var audio_count: int = 0 ## The instances of this [AudioStreamMP3] currently playing.

## Takes [param amount] to change the [member audio_count]. 
func change_audio_count(amount: int) -> void:
	audio_count = max(0, audio_count + amount)


## Checkes whether the audio limit is reached. Returns true if the [member audio_count] is less than the [member limit].
func has_open_limit() -> bool:
	return audio_count < limit


## Connected to the [member sound_effect]'s finished signal to decrement the [member audio_count].
func on_audio_finished() -> void:
	change_audio_count(-1)