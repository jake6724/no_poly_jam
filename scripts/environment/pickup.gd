class_name Pickup
extends CharacterBody3D

@export var mesh: MeshInstance3D

var currency: PlayerInventory.Currency

func _ready():
	currency = PlayerInventory.get_weighted_random_metal_currency()
	mesh.material_override = PlayerInventory.currency_materials[currency]
