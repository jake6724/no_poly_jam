class_name Doorway
extends Node3D

@export var area: Area3D

func _ready():
    area.body_entered.connect(on_area_body_entered)

func on_area_body_entered(player: Player) -> void:
    player.hide()
    player.input_enabled = false
    AudioManager.change_music_track(SoundEffect.SOUND_EFFECT_TYPE.MUSIC_MAIN)
    SceneTransition.target_scene = SceneTransition.MALL_LEVEL
    SceneTransition.transition_out()