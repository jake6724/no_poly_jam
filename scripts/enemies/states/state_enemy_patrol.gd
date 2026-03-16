class_name StateEnemyPatrol
extends State

var patrol_timer: Timer = Timer.new()
var patrol_delay_min: float = 1
var patrol_delay_max: float = 5
var waiting_at_patrol: bool = true

var max_search_offset: float = 10.0

var patrol_started: bool = false

func init_state():
	patrol_timer.one_shot = true
	patrol_timer.autostart = false
	add_child(patrol_timer)
	patrol_timer.timeout.connect(on_patrol_timer_timeout)

func enter_state():
	waiting_at_patrol = false
	update_patrol_position_requested.emit(get_patrol_target_position_offset())

	set_deferred("patrol_started", true)

# TODO: Don't wait for the timer to go off on spawn ,immediately start patrolling !
func state_physics_process(_delta: float, _parent_character: CharacterBody3D):
	if patrol_started:
		if _parent_character.navigation_agent.is_navigation_finished() and not waiting_at_patrol:

			waiting_at_patrol = true
			var _patrol_delay: float = randf_range(patrol_delay_min, patrol_delay_max)
			patrol_timer.start(_patrol_delay)
			update_velocity_requested.emit(Vector3.ZERO)

		elif not waiting_at_patrol:
			update_move_target_to_patrol_position_requested.emit()
			var current_agent_position: Vector3 = _parent_character.global_position # TODO: maybe this chunk should be a state or zombie func
			var next_path_position: Vector3 = _parent_character.navigation_agent.get_next_path_position()
			update_velocity_requested.emit(current_agent_position.direction_to(next_path_position) * _parent_character.move_speed)
 
func on_patrol_timer_timeout() -> void:
	waiting_at_patrol = false
	update_patrol_position_requested.emit(get_patrol_target_position_offset())

func get_patrol_target_position_offset() -> Vector3:
	var patrol_offset: Vector3 = Vector3(randf_range(-max_search_offset, max_search_offset), 0, randf_range(-max_search_offset, max_search_offset))
	return patrol_offset

func exit_state():
	patrol_timer.stop()
	patrol_started = false
