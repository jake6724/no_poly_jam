class_name ZombieSpawner
extends Node3D

@export var player: Player
@export var enabled: bool = true
@export var spawn_amount: int = 0
@export var editor_mesh: MeshInstance3D

var spawn_offset: Vector3 = Vector3(0,0,0)
var spawn_delay: float = .2

const ZOMBIE_SCENE: PackedScene = preload("res://scenes/Enemy/Zombie.tscn")

func _ready():
	if enabled:
		spawn_zombies(spawn_amount)
	editor_mesh.hide()

func spawn_zombies(_amount: int=1):
	for i in range(_amount):
		var new_zombie: Zombie = ZOMBIE_SCENE.instantiate()
		new_zombie.prey = player
		add_child(new_zombie)
		new_zombie.global_position = global_position + spawn_offset
		await get_tree().create_timer(spawn_delay).timeout