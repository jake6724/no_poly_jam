extends Node

var pickups: Array[Pickup] = []

const ROTATION_SPEED_MULTIPLIER: float = 2.0

func _process(delta):
    for pickup: Pickup in pickups:
        pickup.rotation.y += (delta * ROTATION_SPEED_MULTIPLIER)