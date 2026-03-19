class_name StateEnemyChase
extends State

var path_update_timer: Timer = Timer.new()
var min_update_time: float = .16
var max_update_time: float = .32

func _ready():
	path_update_timer.autostart = true
	path_update_timer.one_shot = false
	path_update_timer.wait_time = get_path_update_time()
	add_child(path_update_timer)
	path_update_timer.timeout.connect(on_path_update_timer_timeout)

func enter_state():
	ZombieManager.chasers += 1
	update_move_target_to_prey_requested.emit()
	path_update_timer.start()

func exit_state():
	ZombieManager.chasers -= 1
	path_update_timer.stop()

func state_physics_process(_delta: float, _parent_character: CharacterBody3D):
	if _parent_character.navigation_agent.is_navigation_finished():
		# transition_state.emit(self, "stateenemyattack")
		return
	
	# update_move_target_to_prey_requested.emit()

	var current_agent_position: Vector3 = _parent_character.global_position
	var next_path_position: Vector3 = _parent_character.navigation_agent.get_next_path_position()
	update_velocity_requested.emit(current_agent_position.direction_to(next_path_position) * _parent_character.move_speed)

func on_path_update_timer_timeout() -> void:
	update_move_target_to_prey_requested.emit()

func get_path_update_time() -> float:
	return randf_range(min_update_time, max_update_time)