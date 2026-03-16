class_name Interactable
extends Node3D

@export var interact_hint: Sprite3D
var can_interact: bool = true

func show_interact_hint() -> void:
    if not interact_hint.visible and can_interact:
        interact_hint.show()

func hide_interact_hint() -> void:
    interact_hint.hide()

func interact() -> void:
    pass