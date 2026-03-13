class_name Chest
extends Node3D

@export var interact_hint: Sprite3D

func show_interact_hint() -> void:
    if not interact_hint.visible:
        interact_hint.show()
func hide_interact_hint() -> void:
    interact_hint.hide()

func open_chest() -> void:
    pass