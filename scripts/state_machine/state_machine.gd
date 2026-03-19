class_name StateMachine
extends Node

# Store a hashmap reference to each state 

@export var initial_state: State
var current_state: State
var states: Dictionary[String, State] = {}
var parent_character: CharacterBody3D

signal update_velocity_requested
signal update_move_target_to_prey_requested
signal update_patrol_position_requested
signal update_move_target_to_patrol_position_requested

func initialize(_parent_character: CharacterBody3D):
	parent_character = _parent_character
	# Initialize and store all child states
	var children: Array = get_children()
	for _state in children:
		_state.state_name = _state.name.to_lower()
		states[_state.state_name] = _state
		_state.parent_character = parent_character
		_state.init_state()

		# Connect to state signals
		_state.transition_state.connect(transition)
		_state.update_velocity_requested.connect(on_update_velocity_requested)
		_state.update_move_target_to_prey_requested.connect(on_update_move_target_to_prey_requested)
		_state.update_patrol_position_requested.connect(on_update_patrol_position_requested)
		_state.update_move_target_to_patrol_position_requested.connect(on_update_move_target_to_patrol_position_requested)

	# Configure current state
	if initial_state:
		current_state = initial_state
		current_state.enter_state()
	else:
		push_error("initial_state not set; assign in the editor.")

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.state_physics_process(delta, parent_character)

func transition(prev_state, new_state):
	if prev_state == current_state:
		prev_state.exit_state()
		if new_state in states:
			current_state = states[new_state] # Used passed statename to look-up state ref 
			current_state.enter_state()

		else:
			push_error(str("State '" + new_state + "' does not exist as state machine child"))

func force_transition(new_state_name: String) -> void:
	transition(current_state, new_state_name)
		
func on_update_velocity_requested(_new_velocity: Vector3) -> void:
	update_velocity_requested.emit(_new_velocity)

func on_update_move_target_to_prey_requested() -> void:
	update_move_target_to_prey_requested.emit()

func on_update_patrol_position_requested(_patrol_position_offset) -> void:
	update_patrol_position_requested.emit(_patrol_position_offset)

func on_update_move_target_to_patrol_position_requested() -> void:
	update_move_target_to_patrol_position_requested.emit()
