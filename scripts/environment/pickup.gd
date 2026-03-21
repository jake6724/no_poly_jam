class_name Pickup
extends CharacterBody3D

@export var mesh: MeshInstance3D
@export var mesh_1: MeshInstance3D
@export var mesh_2: MeshInstance3D
@export var mesh_3: MeshInstance3D

var currency: PlayerInventory.Currency

func _ready():
	currency = PlayerInventory.get_weighted_random_metal_currency()
	mesh.material_override = PlayerInventory.currency_materials[currency]

	mesh_1.hide()
	mesh_2.hide()
	mesh_3.hide()

	match currency:
		PlayerInventory.Currency.SCRAP: mesh_1.show()
		PlayerInventory.Currency.STEEL: mesh_2.show()
		PlayerInventory.Currency.TITANIUM: mesh_3.show()