class_name StateEnemyChase
extends State

func state_physics_process(_delta: float, _parent_character: CharacterBody3D):
	if _parent_character.navigation_agent.is_navigation_finished():
		return
	
	update_move_target_to_prey_requested.emit()

	var current_agent_position: Vector3 = _parent_character.global_position
	var next_path_position: Vector3 = _parent_character.navigation_agent.get_next_path_position()
	update_velocity_requested.emit(current_agent_position.direction_to(next_path_position) * _parent_character.movement_speed)
