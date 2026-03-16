extends Node

var pickups: Array[Pickup] = []

const ROTATION_SPEED_MULTIPLIER: float = 2.0
const DEFAULT_SPAWN_DELAY: float = 0.1
const PICKUP_SCENE: PackedScene = preload("res://scenes/Environment/Pickup.tscn")

func _physics_process(delta: float) -> void:
	for pickup: Pickup in pickups:
		pickup.rotation.y += (delta * ROTATION_SPEED_MULTIPLIER)
		pickup.velocity.y -= (30 * delta)

		if pickup.is_on_floor():
			pickup.velocity = pickup.velocity.move_toward(Vector3.ZERO, delta * 20)

		pickup.move_and_slide()

func spawn_pickup(spawn_amount, spawn_global_position: Vector3, forward_direction: Vector3, spawn_delay: float=DEFAULT_SPAWN_DELAY) -> void:
	for i in range(spawn_amount):
		var new_pickup: Pickup = PICKUP_SCENE.instantiate()
		add_child(new_pickup)
		pickups.append(new_pickup)
		new_pickup.global_position = spawn_global_position
		new_pickup.velocity = get_launch_velocity(forward_direction)
		new_pickup.mesh.scale = Vector3(randf_range(.8,1), randf_range(.8,1), randf_range(.8,1))
		await get_tree().create_timer(spawn_delay).timeout

func get_launch_velocity(forward_direction: Vector3) -> Vector3:
	var launch_velocity: Vector3 = forward_direction
	launch_velocity.z = -randf_range(4, 8)
	launch_velocity.x = randf_range(-2, 2)
	launch_velocity.y = randf_range(9, 12)
	return launch_velocity

func remove_pickup(_pickup: Pickup) -> void:
	pickups.erase(_pickup)
	_pickup.queue_free()
