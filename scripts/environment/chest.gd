class_name Chest
extends Interactable

@export var collider: CollisionShape3D

var opened: bool = true

func interact() -> void:
    if not opened:
        hide_interact_hint()
        can_interact = false
        opened = true
        var forward_direction: Vector3 = -global_transform.basis.z.normalized()
        PickupManager.spawn_pickup(5, global_position + Vector3(0, 0, 0), forward_direction)