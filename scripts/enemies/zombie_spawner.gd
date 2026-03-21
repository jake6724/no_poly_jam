class_name ZombieSpawner
extends Node3D

@export var player: Player
@export var enabled: bool = true
@export var spawn_amount: int = 0
@export var editor_mesh: MeshInstance3D
@export var respawn_timer: Timer
@export_range(1, 60, 1) var min_respawn_time: float = 10.0
@export_range(1, 60, 1) var max_respawn_time: float = 10.0

var spawn_offset: Vector3 = Vector3(0,0,0)
var spawn_delay: float = .2

const ZOMBIE_SCENE: PackedScene = preload("res://scenes/Enemy/Zombie.tscn")

func _ready():
	if enabled:
		spawn_zombies(spawn_amount)
	editor_mesh.hide()
	respawn_timer.timeout.connect(on_respawn_timer_timeout)

func spawn_zombies(_amount: int=1):
	for i in range(_amount):
		var new_zombie: Zombie = ZOMBIE_SCENE.instantiate()
		new_zombie.prey = player
		add_child(new_zombie)
		new_zombie.global_position = global_position + spawn_offset
		new_zombie.died.connect(on_zombie_died)
		ZombieManager.add_zombie(new_zombie)
		await get_tree().create_timer(spawn_delay).timeout

func on_zombie_died() -> void:
	respawn_timer.start(randf_range(min_respawn_time, max_respawn_time))

func on_respawn_timer_timeout() -> void:

	# TODO: Check if a spawn limit is available from zombie manager? 

	spawn_zombies(spawn_amount)