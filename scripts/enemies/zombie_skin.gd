class_name ZombieSkin
extends Node3D


@export var mesh_1: MeshInstance3D
@export var mesh_2: MeshInstance3D
@export var mesh_3: MeshInstance3D
@export var mesh_4: MeshInstance3D

@export var skeleton: Skeleton3D
@export var skeleton_physical: PhysicalBoneSimulator3D

@onready var meshes: Array[MeshInstance3D] = [mesh_1, mesh_2, mesh_3, mesh_4]

@export var animation_tree_1: AnimationTree
@export var animation_tree_2: AnimationTree
@export var animation_tree_3: AnimationTree
@onready var animation_trees: Array[AnimationTree] = [animation_tree_1, animation_tree_2, animation_tree_3]
var animation_tree: AnimationTree

var zombie_is_chasing: bool = false
var zombie_is_patrolling: bool = true
var zombie_velocity: Vector3
var zombie_is_attacking: bool = false

signal check_can_attack_requested
signal bite_requested

func _ready():
	mesh_1.hide()
	meshes.pick_random().show()
	animation_tree = animation_tree_1
	animation_tree_1.active = true

	# for _anim_tree: AnimationTree in animation_trees:
	# 	_anim_tree.active = false
	# animation_tree = animation_trees.pick_random()
	# animation_tree.active = true
	
func end_attack() -> void:
	check_can_attack_requested.emit()

func bite(_value: bool) -> void:
	bite_requested.emit(_value)

# func _physics_process(delta):
# 	print("zombie_is_chasing: ", zombie_is_chasing)
# 	print("zombie_is_patrolling: ", zombie_is_patrolling)
# 	print("zombie_velocity.length(): ", zombie_velocity.length())
# 	var state_machine_playback = animation_tree.get("parameters/StateMachine/playback")
# 	print(state_machine_playback.get_current_node())
