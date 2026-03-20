extends Node

var zombies: Array[Zombie] = []

var chasers: int = 0
var chase_limit: int = 60

func add_zombie(_zombie: Zombie) -> void:
	zombies.append(_zombie)

func clear_all_zombies() -> void:
	zombies = []

func remove_zombie(_zombie: Zombie) -> void:
	zombies.erase(_zombie)
	_zombie.queue_free()

func _physics_process(delta: float) -> void:
	for _zombie: Zombie in zombies:
		_zombie.child_physics_process(delta)

func has_open_chase_limit() -> bool:
	return chasers < chase_limit
