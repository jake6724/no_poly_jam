class_name Upgrade
extends Interactable

const ROTATION_SPEED_MULTIPLIER: float = 1.2

@export var mesh: MeshInstance3D

func _process(delta):
	mesh.rotation.y += (delta * ROTATION_SPEED_MULTIPLIER)
