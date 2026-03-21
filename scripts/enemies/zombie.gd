class_name Zombie
extends CharacterBody3D

var movement_target_position: Vector3
var rotation_offset: float = PI/2 #https://www.youtube.com/watch?v=WgR4QMlFVvI
@export var prey: Node3D 
@export_group("Nodes")
@export var body_collider: CollisionShape3D
@export var state_machine: StateMachine
@export var sight_area_player: Area3D
@export var sight_area_player_collider: CollisionShape3D
@export var raycast_sight: RayCast3D
@export var chase_area: Area3D
@export var chase_area_collider: CollisionShape3D
@export var alert_area: Area3D
@export var alert_area_collider: CollisionShape3D
@export var attack_area: Area3D
@export var attack_collider: CollisionShape3D
@export var bite_area: Area3D
@export var bite_collider: CollisionShape3D
@export var navigation_agent: NavigationAgent3D
@export var skin: ZombieSkin
@export var growl_timer: Timer

var patrol_position: Vector3
var is_player_in_sight_range: bool = false
var player_spotted: bool = false
var chase_timer: Timer = Timer.new()
@export_group("Stats")
@export var max_health: float = 100.0
@export var health: float
@export var move_speed_min: float = 4.0
@export var move_speed_max: float = 7.0
@export var move_speed: float 
@export var line_of_sight_angle: float = 70.0
@export var rotation_speed: float = TAU * 2
@export var gravity: float = -30
@export var bite_damage: float = 10.0
@export var pickup_spawn_chance: float = 0.3
## Min Duration after player has escaped zombie chase range that zombie will keep chasing
@export_range(1,10,.5)var chase_duration_min: float = 5.0
## Max Duration after player has escaped zombie chase range that zombie will keep chasing
@export_range(1,10,.5)var chase_duration_max: float = 10.0
var is_alive: bool = true

var on_hit_velocity_bonus: Vector3

var prev_state: String

var can_process: bool = true

var gore: PackedScene = preload("res://scenes/Gore.tscn")

signal died

func _ready():
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

	skin.check_can_attack_requested.connect(on_check_can_attack_requested)
	skin.bite_requested.connect(on_bite_requested)

	attack_area.body_entered.connect(on_attack_area_body_entered)
	bite_area.body_entered.connect(on_bite_area_entered)

	growl_timer.timeout.connect(on_growl_timer_timeout)
	growl_timer.start(randf_range(0,8))

func configure_state_machine() -> void:
	state_machine.initialize(self)
	state_machine.update_velocity_requested.connect(on_state_machine_update_velocity_requested)
	state_machine.update_move_target_to_prey_requested.connect(set_move_target_to_prey)
	state_machine.update_patrol_position_requested.connect(update_patrol_position)
	state_machine.update_move_target_to_patrol_position_requested.connect(set_move_target_to_patrol_position)
	state_machine.attack_requested.connect(attack)
	state_machine.update_velocity_to_player_requested.connect(on_state_machine_update_velocity_to_player_requested)

func child_physics_process(delta):
	if can_process:
		if not is_on_floor():
			velocity.y += gravity * delta
		else:
			velocity.y = 0

		# Face move direction (maybe use this? -global_transform.basis.z.normalized())
		var velocity_without_y = Vector3(velocity.x, 0, velocity.z)
		var target_position: Vector3 = global_position + velocity_without_y
		var _move_direction = target_position - global_position
		if _move_direction:
			rotation.y = rotate_toward(rotation.y, (Vector2(_move_direction.x, -_move_direction.z).angle()) + PI/2, rotation_speed * delta)

		if is_player_in_sight_range and prey and not player_spotted:
			look_for_player(prey)

		state_machine.child_physics_process(delta)

		on_hit_velocity_bonus.move_toward(Vector3.ZERO, delta * 10)

		move_and_slide()

# Update Skin Animation param
	skin.zombie_is_chasing = player_spotted
	skin.zombie_is_patrolling = not player_spotted
	skin.zombie_velocity = velocity

## Can be requested by child States. Does not require the State to have access to Move Target
func set_move_target_to_prey():
	if prey and state_machine.current_state.state_name == "stateenemychasebasic":
		navigation_agent.set_target_position(prey.global_position)

func update_patrol_position(_patrol_position_offset):
	patrol_position = global_position + _patrol_position_offset
	navigation_agent.set_target_position(patrol_position)

func set_move_target_to_patrol_position():
	navigation_agent.set_target_position(patrol_position)

func on_state_machine_update_velocity_requested(_new_velocity) -> void:
	velocity = _new_velocity

func on_state_machine_update_velocity_to_player_requested() -> void:
	if prey:
		var direction = global_position.direction_to(prey.global_position)
		direction.y = 0
		var velocity_y = velocity.y
		velocity = move_speed * direction
		velocity.y = velocity_y

func on_body_entered_sight_area_player(_body) -> void:
	if _body is Player:
		chase_timer.stop()
		is_player_in_sight_range = true
		prey = _body

func on_body_exited_sight_area_player(_body) -> void:
	if _body is Player:
		is_player_in_sight_range = false

func on_chase_area_body_exited(_body) -> void:
	if is_alive:
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

func start_chasing(_prey: Player, was_attacked: bool=false) -> void:
	if ZombieManager.has_open_chase_limit() or was_attacked:
		player_spotted = true
		state_machine.force_transition("stateenemychasebasic")
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
			
func on_attack_area_body_entered(_player: Player) -> void:
	attack()
			
func attack() -> void:
	if state_machine.current_state.state_name != "stateenemyattack":
		state_machine.force_transition("stateenemyattack")
		skin.zombie_is_attacking = true

func on_check_can_attack_requested() -> void:
	if attack_area.get_overlapping_bodies().size() <= 0:
		skin.zombie_is_attacking = false
		state_machine.force_transition("stateenemychasebasic")

func on_bite_requested(_value: bool) -> void:
	bite_collider.disabled = not _value

func on_bite_area_entered(_player: Player) -> void:
	_player.take_damage(bite_damage)

func take_damage(_damage_amount: float, player: Player) -> void:
	# can_process = false
	# skin.animation_tree_1.active = false
	# body_collider.disabled = true
	# skin.skeleton_physical.physical_bones_start_simulation()

	# Start chasing if ambushed
	if not player_spotted:
		var bodies: Array = chase_area.get_overlapping_bodies()
		if bodies.size() > 0:
			start_chasing(bodies[0], true)

	# flash_mesh()
	skin.animation_tree["parameters/HitOneShot/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	health -= _damage_amount
	AudioManager.create_3d_audio_at_location(global_position, SoundEffect.SOUND_EFFECT_TYPE.ZOMBIE_HIT)
	PopupManager.spawn_popup(global_position + Vector3(0,1,0), _damage_amount)
	if health < 0:
		var impulse = -(global_position.direction_to(player.global_position)) * 30
		die(impulse)

	# on_hit_velocity_bonus = -(global_position.direction_to(player.global_position)) * 200
	# prev_state = state_machine.current_state.state_name

func die(impulse) -> void:
	is_alive = false
	ZombieManager.remove_zombie(self)
	spawn_gore(global_position + Vector3(0, 1, 0), impulse, 3)
	var forward_direction: Vector3 = -global_transform.basis.z.normalized()
	if randf() < pickup_spawn_chance:
		PickupManager.spawn_pickup(1, global_position + Vector3(0, 0, 0), forward_direction)
	died.emit()

func spawn_gore(_transform, impulse: Vector3, amount: int) -> void:
	for i in range(amount):
		impulse += Vector3(randf_range(-30,30), randf_range(-30,30), 0)
		var new_gore: Gore = gore.instantiate()

		ZombieManager.add_child(new_gore)
		new_gore.global_position = _transform
		new_gore.apply_impulse(impulse)

func on_growl_timer_timeout() -> void:
	AudioManager.create_3d_audio_at_location(global_position, SoundEffect.SOUND_EFFECT_TYPE.ZOMBIE_NOISE)
	growl_timer.start(randf_range(3, 60))