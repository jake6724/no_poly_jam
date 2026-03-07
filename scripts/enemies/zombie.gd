class_name Zombie
extends CharacterBody3D

var movement_speed: float = 7.0
var movement_target_position: Vector3
@export var prey: Node3D
@export_group("Nodes")
@export var state_machine: StateMachine

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D

var patrol_position: Vector3

func _ready():
	# These values need to be adjusted for the actor's speed
	# and the navigation layout.
	navigation_agent.path_desired_distance = 0.5
	navigation_agent.target_desired_distance = 0.5

	# Make sure to not await during _ready.
	initialize.call_deferred()

	configure_state_machine()

func initialize():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame

	# Now that the navigation map is no longer empty, set the movement target.
	set_move_target_to_prey()

func configure_state_machine() -> void:
	state_machine.initialize(self)
	state_machine.update_velocity_requested.connect(on_state_machine_update_velocity_requested)
	state_machine.update_move_target_to_prey_requested.connect(set_move_target_to_prey)
	state_machine.update_patrol_position_requested.connect(update_patrol_position)
	state_machine.update_move_target_to_patrol_position_requested.connect(set_move_target_to_patrol_position)

func _physics_process(_delta):
	# print(velocity)
	move_and_slide()

## Can be requested by child States. Does not require the State to have access to Move Target
func set_move_target_to_prey():
	if prey:
		navigation_agent.set_target_position(prey.global_position)

func update_patrol_position(_patrol_position_offset):
	patrol_position = global_position + _patrol_position_offset
	navigation_agent.set_target_position(patrol_position)

func set_move_target_to_patrol_position():
	navigation_agent.set_target_position(patrol_position)

func on_state_machine_update_velocity_requested(_new_velocity) -> void:
	velocity = _new_velocity
