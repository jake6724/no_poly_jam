class_name MainMenu
extends Control

@export var button_new_game: Button
@export var button_settings: Button

func _ready():
    button_new_game.pressed.connect(on_new_game_pressed)

func on_new_game_pressed() -> void:
    SceneTransition.transition_out()