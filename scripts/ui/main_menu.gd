class_name MainMenu
extends Control

@export var button_new_game: Button
@export var button_settings: Button

func _ready():
    button_new_game.pressed.connect(on_new_game_pressed)
    # AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.MUSIC_MAIN)

func on_new_game_pressed() -> void:
    AudioManager.change_music_track(SoundEffect.SOUND_EFFECT_TYPE.MUSIC_LOBBY)
    SceneTransition.transition_out()
    HowToGlobal.go()