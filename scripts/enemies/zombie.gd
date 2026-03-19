class_name Zombie
extends CharacterBody3D

var movement_target_position: Vector3
var rotation_offset: float = PI/2 #https://www.youtube.com/watch?v=WgR4QMlFVvI
@export var prey: Node3D 
@export_group("Nodes")
@export var state_machine: StateMachine
@export var sight_area_player: Area3D
@export var sight_area_player_collider: CollisionShape3D
@export var raycast_sight: RayCast3D
@export var chase_area: Area3D
@export var chase_area_collider: CollisionShape3D
@export var alert_area: Area3D
@export var alert_area_collider: CollisionShape3D
@export var navigation_agent: NavigationAgent3D
@export var skin: MeshInstance3D
@export var ground_raycast: RayCast3D

var patrol_position: Vector3
var is_player_in_sight_range: bool = false
var player_spotted: bool = false
var chase_timer: Timer = Timer.new()
var chase_duration_min: float = 5.0 # Duration after player has escaped zombie chase range that zombie will keep chasing
var chase_duration_max: float = 10.0
@export_group("Stats")
@export var max_health: float = 100.0
@export var health: float
@export var move_speed_min: float = 4.0
@export var move_speed_max: float = 7.0
@export var move_speed: float 
@export var line_of_sight_angle: float = 70.0
@export var rotation_speed: float = TAU * 2
@export var gravity: float = -30
var is_alive: bool = true

func _ready():
	max_slides = 2
	# These values need to be adjusted for the actor's speed
	# and the navigation layout.
	navigation_agent.path_desired_distance = 0.5
	navigation_agent.target_desired_distance = 0.5

	move_speed = randf_range(move_speed_min, move_speed_max)

	# Configure SightArea
	sight_area_player.body_entered.connect(on_body_entered_sight_area_player)
	sight_area_player.body_exited.connect(on_body_exited_sight_area_player)	

	# Configure Chasing
	chase_area.body_exited.connect(on_chase_area_body_exited)
	chase_timer.one_shot = true
	chase_timer.autostart = false
	add_child(chase_timer)
	chase_timer.timeout.connect(on_chase_timer_timeout)

	raycast_sight.debug_shape_thickness = 10

	configure_state_machine()

	# Configure stats
	health = max_health

func configure_state_machine() -> void:
	state_machine.initialize(self)
	state_machine.update_velocity_requested.connect(on_state_machine_update_velocity_requested)
	state_machine.update_move_target_to_prey_requested.connect(set_move_target_to_prey)
	state_machine.update_patrol_position_requested.connect(update_patrol_position)
	state_machine.update_move_target_to_patrol_position_requested.connect(set_move_target_to_patrol_position)

func _physics_process(delta):
	# Gravity 
	# velocity.y = (velocity.y + (gravity * delta))
	
	position.y = ground_raycast.get_collision_point().y - 1.9

	# Face move direction (maybe use this? -global_transform.basis.z.normalized())
	var target_position: Vector3 = global_position + velocity
	var _move_direction = target_position - global_position
	if _move_direction:
		rotation.y = rotate_toward(rotation.y, Vector2(_move_direction.x, -_move_direction.z).angle() - rotation_offset, rotation_speed * delta)

	if is_player_in_sight_range and prey and not player_spotted:
		look_for_player(prey)

	move(velocity, delta)

func move(_curr_velocity: Vector3, delta) -> void:
	# Gravity 
	# if not is_on_floor():
	# 	_curr_velocity.y = (_curr_velocity.y + (gravity * delta))
	
	var collision: KinematicCollision3D = move_and_collide(_curr_velocity * delta)
	if collision:
		var collider:Object = collision.get_collider()
		if collider is CharacterBody3D:
			print("Char")
			velocity = _curr_velocity.slide(collision.get_normal())

		elif collider is StaticBody3D:
			#print("Ground")
			move_and_slide()

## Can be requested by child States. Does not require the State to have access to Move Target
func set_move_target_to_prey():
	if prey and state_machine.current_state.state_name == "stateenemychase":
		if ZombieManager.has_path_update_token_available():
			navigation_agent.set_target_position(prey.global_position)
			ZombieManager.path_call_count += 1

func update_patrol_position(_patrol_position_offset):
	patrol_position = global_position + _patrol_position_offset
	navigation_agent.set_target_position(patrol_position)

func set_move_target_to_patrol_position():
	navigation_agent.set_target_position(patrol_position)

func on_state_machine_update_velocity_requested(_new_velocity) -> void:
	velocity = _new_velocity

func on_body_entered_sight_area_player(_body) -> void:
	if _body is Player:
		chase_timer.stop()
		is_player_in_sight_range = true
		prey = _body

func on_body_exited_sight_area_player(_body) -> void:
	if _body is Player:
		is_player_in_sight_range = false

func on_chase_area_body_exited(_body) -> void:
	if player_spotted:
		chase_timer.start(randf_range(chase_duration_min, chase_duration_max))

func look_for_player(player: Player) -> void:
	var forward_vector: Vector3 = -global_transform.basis.z.normalized()
	var direction_to_player = (player.global_transform.origin - global_transform.origin).normalized()
	var angle_to_player = rad_to_deg(forward_vector.angle_to(direction_to_player))
	if angle_to_player <= line_of_sight_angle:
		raycast_sight.target_position = raycast_sight.to_local(player._capsule_collider.global_position)
		raycast_sight.force_raycast_update()
		if raycast_sight.get_collider() is Player:
			start_chasing(player)
			alert_nearby_zombies()

func start_chasing(_prey: Player) -> void:
	player_spotted = true
	state_machine.force_transition("stateenemychase")
	prey = _prey # Set again here to ensure that alerted zombies (which may not have seen player yet) have a reference

func on_chase_timer_timeout() -> void:
	player_spotted = false
	state_machine.force_transition("stateenemypatrol")
	prey = null

func alert_nearby_zombies() -> void:
	var bodies: Array[Node3D] = alert_area.get_overlapping_bodies()
	for body: Node3D in bodies:
		var zombie: Zombie = body as Zombie
		if zombie:
			zombie.start_chasing(prey)

func take_damage(_damage_amount: float) -> void:
	# Start chasing if ambushed
	if not player_spotted:
		var bodies: Array = chase_area.get_overlapping_bodies()
		start_chasing(bodies[0])

	flash_mesh()
	health -= _damage_amount
	if health < 0:
		die()

func die() -> void:
	queue_free()

func flash_mesh() -> void:
	var mat = skin.get_surface_override_material(0)
	var reset_color: Color = mat.albedo_color

	var flash_tween: Tween = get_tree().create_tween()
	flash_tween.set_parallel(true)
	flash_tween.tween_property(mat, "albedo_color:s", 1, .3).from(15)
	flash_tween.tween_property(mat, "albedo_color", reset_color, .3).from(Color.SALMON)

	# mat.albedo_color.s = 15
