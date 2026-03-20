class_name Gore
extends RigidBody3D

@export var mesh_1: MeshInstance3D
@export var mesh_2: MeshInstance3D
@export var mesh_3: MeshInstance3D
@export var mesh_4: MeshInstance3D
@onready var meshes: Array[MeshInstance3D]  = [mesh_1, mesh_2, mesh_3, mesh_4]

func _ready():
	meshes.pick_random().show()
