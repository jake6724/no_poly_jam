class_name Chest
extends Interactable

var opened: bool = false

func interact() -> void:
    if not opened:
        hide_interact_hint()
        can_interact = false
        opened = true
        var forward_direction: Vector3 = -global_transform.basis.z.normalized()
        PickupManager.spawn_pickup(5, global_position + Vector3(0, 0, 0), forward_direction)