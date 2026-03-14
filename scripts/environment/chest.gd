class_name Chest
extends Node3D

@export var interact_hint: Sprite3D
var opened: bool = false

func show_interact_hint() -> void:
    if not interact_hint.visible and not opened:
        interact_hint.show()

func hide_interact_hint() -> void:
    interact_hint.hide()

func open_chest() -> void:
    if not opened:
        opened = true
        var forward_direction: Vector3 = -global_transform.basis.z.normalized()
        PickupManager.spawn_pickup(5, global_position + Vector3(0, 0, 0), forward_direction)