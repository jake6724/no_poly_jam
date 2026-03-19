extends Node

var zombies: Array[Zombie] = []
var chasing_zombies: Array[Zombie] = []

var path_call_count: int = 0

var path_update_tokens_max: int = 100
var path_update_tokens_active: int = 0

func add_zombie(_zombie: Zombie, spawn_global_position: Vector3) -> void:
    # pass
    # add_child(_zombie)
    # _zombie.global_position = spawn_global_position
    zombies.append(_zombie)
    # print(zombies)

func add_zombie_to_chase(_zombie: Zombie) -> void:
    chasing_zombies.append(_zombie)

func remove_zombie_from_chase(_zombie: Zombie) -> void:
    chasing_zombies.erase(_zombie)

func _physics_process(_delta: float) -> void:
    if path_call_count > 5:
        print(path_call_count)
    path_call_count = 0
    path_update_tokens_active = 0
    pass
    # for zombie: Zombie in chasing_zombies:
    #     print(zombie)

    # for zombie: Zombie in zombies:
    #     if zombie.state_machine.current_state.state_name == "stateenemychase":
    #         print("Test")

func has_path_update_token_available() -> bool:
    if path_update_tokens_active < path_update_tokens_max:
        path_update_tokens_active += 1
        return true
    else:
        return false