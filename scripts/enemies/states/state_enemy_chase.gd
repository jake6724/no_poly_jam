class_name StateEnemyChase
extends State

var path_timer: Timer = Timer.new()

func _ready():
	path_timer.one_shot = true
	path_timer.autostart = false
	add_child(path_timer)
	path_timer.timeout.connect(on_path_timer_timeout)

func enter_state():
	update_move_target_to_prey_requested.emit()
	path_timer.start(randf_range(.17, .5))
	ZombieManager.add_zombie_to_chase(owner)

func exit_state():
	ZombieManager.remove_zombie_from_chase(owner)

func state_physics_process(_delta: float, _parent_character: CharacterBody3D):
	if _parent_character.navigation_agent.is_navigation_finished():
		return
		
	# update_move_target_to_prey_requested.emit()

	var current_agent_position: Vector3 = _parent_character.global_position
	var next_path_position: Vector3 = _parent_character.navigation_agent.get_next_path_position()
	update_velocity_requested.emit(current_agent_position.direction_to(next_path_position) * _parent_character.move_speed)

func on_path_timer_timeout() -> void:
	update_move_target_to_prey_requested.emit()
	path_timer.start(randf_range(.17,.5))
