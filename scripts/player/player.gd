class_name Player
extends CharacterBody3D

# https://github.com/godotengine/godot/issues/69771
# Spring arm behavior is weird when close to wall geomertry. Can fix this mostly by leaving shape empty for the spring arm
# This will make it take on the shape of the camera which I guess fixes it

# Stair stepping
# https://github.com/kelpysama/Godot-Stair-Step-Demo/blob/main/Scripts/player_character.gd

@export_group("Player Settings")
@export_range(0, 1.0) var mouse_sensitivty: float = 0.25
@export var rotation_speed: float = 12.0
@export_range(1, 20, 1) var zoom_sensitivity: float = .5
@export_range(.1, 10, .1) var zoom_step: float = 1
@export_range(3, 10, 1) var zoom_min: float = 3
@export_range(5, 20, 1) var zoom_max: float = 10
@export var right_click_to_rotate_camera: bool = false
var input_enabled: bool = true
@export_group("Movement")
@export var move_speed: float = 8.0
@export var move_speed_sprint: float = 10.0
var move_speed_base: float 
var is_sprinting: bool = false
var max_speed: float = 200
@export var slide_timer: Timer
@export_range(.1, 5, .1) var slide_cooldown: float
var can_slide: bool = true
var is_sliding: bool = false
var prev_floor_angle: float 
var slide_multiplier: float
@export var slide_bite_area: Area3D
@export var slide_bite_collider: CollisionShape3D
@export var slide_pierce_max: int = 100
var slide_pierce_count: int = 0
@export var slide_pierce_label: Label3D
var slide_power: float = 23.0

var is_grounded: bool = false
var was_grounded: bool = false
var move_direction: Vector3
@export_range(20,100,1) var acceleration: float = 20.0
@export var jump_power: float = 12.0
var can_stair_step: bool = true # Disabled when jumping until jump coyote time goes off, or grounded. Prevents player from snapping back to ground when jumping
@export_range(0,1,.1) var jump_coyote_time: float = 0.5
@export var gravity: float = -30
@export_group("Combat")
@export var max_health: float = 100.0
var health: float 
@export_range(.1, 3, .1) var bite_cooldown: float
var can_bite: bool = true
@export var bite_area: Area3D
@export var bite_collider: CollisionShape3D
@export var base_damage: float = 25
var damage: float
var damage_divider: float = 20

@export_group("Nodes")
@export var _camera: Camera3D
@export var _camera_pivot: Node3D
@export var _spring_arm: SpringArm3D
@export var _capsule_collider: CollisionShape3D
var _camera_input_direction: Vector2 = Vector2.ZERO
var _rotate_camera: bool = false
@export var grapple_raycast: RayCast3D
@export var grapple_controller: GrappleController
var grapple_distance: float = 30
@export var grapple_cursor: MeshInstance3D
@export var interact_raycast: RayCast3D
@export var pickup_collect_area: Area3D
@export var pickup_collect_collider: CollisionShape3D
@export var body_collider: CollisionShape3D

var respawn_timer: Timer = Timer.new()

# Stairs
const MAX_STEP_DOWN = -.5
const MAX_STEP_UP = .5
var vertical := Vector3(0, 1, 0)		# Shortcut for converting vectors to vertical

var zoom_target: float

const MOVE_DIRECTION_THRESHOLD: float = 0.2

@export var player_ui: PlayerUI
@export var _skin: RexSkin

var coyote_jump_available: bool = true
var coyote_jump_timer: Timer = Timer.new()
var prev_is_on_floor: bool = true

var prev_interactable: Node3D

func _ready():
	zoom_target = _spring_arm.spring_length 
	move_speed_base = move_speed
	coyote_jump_timer.one_shot = true
	coyote_jump_timer.autostart = false
	add_child(coyote_jump_timer)
	coyote_jump_timer.timeout.connect(on_coyote_jump_timer_timeout)
	_rotate_camera = not right_click_to_rotate_camera

	pickup_collect_area.area_entered.connect(on_pickup_collect_area_entered)

	_skin.bite_finished.connect(on_bite_finished)
	_skin.bite_collider_requested.connect(on_bite_collider_requested)

	# BiteArea
	bite_area.body_entered.connect(on_bite_body_entered)
	slide_bite_area.body_entered.connect(on_bite_body_entered)

	# SlideTimer
	slide_timer.timeout.connect(on_slide_timer_timeout)

	bite_collider.disabled = true
	
	damage = base_damage

	grapple_controller.grapple_rope = _skin.tongue
	grapple_raycast.target_position = Vector3(0, -1.0, -grapple_distance)

	health = max_health
	player_ui.update_health(100)

	respawn_timer.one_shot = true
	respawn_timer.autostart = false
	add_child(respawn_timer)
	respawn_timer.timeout.connect(on_respawn_timer_timeout)

	slide_pierce_label.text = ""

func on_respawn_timer_timeout() -> void:
	pass

func _input(_event):
	if input_enabled:
		if Input.is_action_just_pressed("left_click"):
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

		if Input.is_action_just_pressed("escape"):
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

		if Input.is_action_just_pressed("sprint"):
			move_speed = move_speed_sprint
			is_sprinting = true
			# _skin.animation_tree.set("parameters/TimeScale/scale", 1.25)

		if Input.is_action_just_released("sprint"):
			move_speed = move_speed_base
			is_sprinting = false
			_skin.animation_tree.set("parameters/TimeScale/scale", 1.0)

		if Input.is_action_just_pressed("jump"):
			jump()
			can_stair_step = false

		if Input.is_action_just_pressed("control"):
			slide()

		if Input.is_action_just_released("control"):
			stop_slide()

		if Input.is_action_just_pressed("interact"):
			interact()

func _unhandled_input(event: InputEvent) -> void:
	if input_enabled:
		# Check mouse has moved
		var is_camera_motion: bool = (event is InputEventMouseMotion) and (Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED)
		if is_camera_motion:
			_camera_input_direction = event.screen_relative * mouse_sensitivty

		if Input.is_action_just_pressed("scroll_up"):
			zoom_target -= zoom_step
		if Input.is_action_just_pressed("scroll_down"):
			zoom_target += zoom_step

func _process(delta):
	if not is_equal_approx(_spring_arm.spring_length, zoom_target):
		zoom_target = clamp(zoom_target, zoom_min, zoom_max)
		_spring_arm.spring_length = lerp(_spring_arm.spring_length, zoom_target, zoom_sensitivity * delta)

	if interact_raycast.is_colliding():

		# TODO: Put a lil mesh where it is colliding so I can see how it looks

		var interactable: Interactable = interact_raycast.get_collider().owner as Interactable
		if interactable:
			interactable.show_interact_hint()
			prev_interactable = interactable
	else:
		if prev_interactable:
			prev_interactable.hide_interact_hint()
			prev_interactable = null

func _physics_process(delta: float) -> void:
	#print(get_real_velocity().length())
	if Input.is_action_pressed("left_click") and can_bite and input_enabled:
		can_bite = false
		_skin.bite()

	was_grounded = is_grounded
	is_grounded = is_on_floor()

	if _rotate_camera:
		# Set X and Y camera rotation. Clamp X axis so player cannot look fully up or down
		_camera_pivot.rotation.x -= _camera_input_direction.y * delta
		_camera_pivot.rotation.y -= _camera_input_direction.x  * delta
		_camera_pivot.rotation.x = clamp(_camera_pivot.rotation.x, (-PI / 4.0), (PI / 6.0))

	# Reset _camera_input_direction for the next time _unhandled_input() is triggered
	# If this is not reset, the camera will keep rotating until new input comes in
	_camera_input_direction = Vector2.ZERO
	var raw_input: Vector2 = Vector2.ZERO
	if not is_sliding and input_enabled:
		# Get the raw 2-axis input data, forward direction of camera, and right direction of camera
		# Forward direction is used to move back-and-forth, right direction is used to move left-and-right
		raw_input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	var forward_direction: Vector3 = _camera.global_basis.z
	var right_direction: Vector3 = _camera.global_basis.x

	# Final move direction is the sum of back-and-forth and left-and-right movement
	move_direction = (forward_direction * raw_input.y) + (right_direction * raw_input.x)
	move_direction.y = 0.0 # Player will never give up-and-down move input. Jumping and falling with handle this
	move_direction = move_direction.normalized() # This is just intended to be a direction vector so it needs to be normalized

	# Acceleration can be added by using move_toward(). This will also prevent overshooting inheritly
	var y_velocity = velocity.y
	velocity.y = 0.0
	velocity = velocity.move_toward((move_direction * move_speed), acceleration * delta)
	velocity.y = (y_velocity + (gravity * delta))

	if velocity.length() > max_speed:
		velocity = velocity.normalized() * max_speed

	if prev_is_on_floor != is_on_floor() and not is_on_floor():
		coyote_jump_timer.start(jump_coyote_time)

	if can_stair_step:
		stair_step_up()

	move_and_slide()
	# stair_step_down()

	_skin.global_rotation.y = lerp_angle(_skin.global_rotation.y, _camera.global_rotation.y + PI , rotation_speed * delta)

	# Animate
	if not is_on_floor() and velocity.y <= 0:
		_skin.fall()
		
	elif is_on_floor():
		can_stair_step = true
		coyote_jump_available = true
		coyote_jump_timer.stop()
		var ground_speed: float = velocity.length()
		if ground_speed > 1.0:
			_skin.move()
		else:
			_skin.idle()

	prev_is_on_floor = is_on_floor()

	_skin.player_velocity = velocity
	_skin.player_is_grounded = is_grounded
	_skin.player_is_sliding = is_sliding
	_skin.player_is_sprinting = is_sprinting

	# _skin.player_move_direction.x = get_real_velocity().x
	# _skin.player_move_direction.y = get_real_velocity().y
	# # _skin.player_move_direction = _skin.player_move_direction.normalized()

	_skin.player_input.y = lerp(_skin.player_input.y, raw_input.y, delta * 10)
	_skin.player_input.x = lerp(_skin.player_input.x, raw_input.x, delta * 8)

func slide() -> void: 
	# if not is_sliding and prev_floor_angle < 0.99 and get_real_velocity().y < 0: 
	# old code idk this doesnt necessarily go on this line here
	if can_slide:
		
		can_slide = false
		is_sliding = true
		_skin.player_is_sliding = true

		acceleration = 3.0
		var floor_angle: float = get_floor_angle()
		var velocity_power_bonus: float = slide_power + (floor_angle * 2)
		velocity = velocity.normalized() * velocity_power_bonus

		slide_bite_collider.disabled = false
		set_collision_mask_value(2, false)
		
		slide_pierce_label.show()

func stop_slide() -> void:
	is_sliding = false
	slide_timer.start(slide_cooldown)
	acceleration = 70.0
	slide_bite_collider.disabled = true
	_skin.stop_slide()
	set_collision_mask_value(2, true)
	slide_pierce_count = 0
	slide_pierce_label.text = ""
	slide_pierce_label.scale = Vector3(1,1,1)
	slide_pierce_label.hide()

func on_bite_body_entered(intruder) -> void:
	var final_damage = damage * get_real_velocity().length()/damage_divider
	intruder.take_damage(int(final_damage), self)
	
	if is_sliding:
		slide_pierce_count += 1
		scale_slide_label()
		slide_pierce_label.text = "x" + str(slide_pierce_count)
		if slide_pierce_count >= slide_pierce_max:
			stop_slide()

func on_bite_collider_requested(_value: bool) -> void:
	bite_collider.set_deferred("disabled", _value)

func jump() -> void:
	if is_on_floor() or grapple_controller.launched or coyote_jump_available:
		grapple_controller.launched = false
		coyote_jump_available = false
		velocity.y = jump_power
		_skin.jump()

func on_coyote_jump_timer_timeout() -> void:
	can_stair_step = true
	coyote_jump_available = false

func interact() -> void:
	if interact_raycast.is_colliding():
		var interactable: Interactable = interact_raycast.get_collider().owner as Interactable
		if interactable:
			interactable.interact()

func on_pickup_collect_area_entered(_intruder) -> void:
	var pickup: Pickup = _intruder.owner as Pickup
	if pickup:
		PlayerInventory.add_currency(pickup.currency)
		PickupManager.remove_pickup(pickup)
		player_ui.update()

func on_bite_finished() -> void:
	can_bite = true

func on_slide_timer_timeout() -> void:
	can_slide = true

func take_damage(_damage) -> void:
	health = max(0, health - _damage)
	player_ui.update_health((health/max_health) * 100)
	if health <= 0:
		die()
	else:
		_skin.hit()

func die() -> void:
	input_enabled = false
	_skin.player_died = true
	zoom_target = 1000
	zoom_step = .25

func scale_slide_label() -> void:
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(slide_pierce_label, "scale", slide_pierce_label.scale + Vector3(.05,.05,.05), .1)
	tween.tween_interval(.1)
	tween.tween_property(slide_pierce_label, "scale", slide_pierce_label.scale - Vector3(.025,.025,.025), .1)

func stair_step_down():
	if is_on_floor():
		return

	# If we're falling from a step
	if velocity.y <= 0 and was_grounded:
		# Initialize body test variables
		var body_test_result = PhysicsTestMotionResult3D.new()
		var body_test_params = PhysicsTestMotionParameters3D.new()

		body_test_params.from = self.global_transform			## We get the player's current global_transform
		body_test_params.motion = Vector3(0, MAX_STEP_DOWN, 0)	## We project the player downward

		if PhysicsServer3D.body_test_motion(self.get_rid(), body_test_params, body_test_result):
			# Enters if a collision is detected by body_test_motion
			# Get distance to step and move player downward by that much
			position.y += body_test_result.get_travel().y
			apply_floor_snap()
			is_grounded = true

func stair_step_up():
	if move_direction == Vector3.ZERO:
		return

	# 0. Initialize testing variables
	var body_test_params = PhysicsTestMotionParameters3D.new()
	var body_test_result = PhysicsTestMotionResult3D.new()

	var test_transform = global_transform				## Storing current global_transform for testing
	var distance = move_direction * 0.1						## Distance forward we want to check
	body_test_params.from = self.global_transform		## Self as origin point
	body_test_params.motion = distance					## Go forward by current distance

	# Pre-check: Are we colliding?
	if !PhysicsServer3D.body_test_motion(self.get_rid(), body_test_params, body_test_result):
		## If we don't collide, return
		return

	# 1. Move test_transform to collision location
	var remainder = body_test_result.get_remainder()							## Get remainder from collision
	test_transform = test_transform.translated(body_test_result.get_travel())	## Move test_transform by distance traveled before collision

	# 2. Move test_transform up to ceiling (if any)
	var step_up = MAX_STEP_UP * vertical
	body_test_params.from = test_transform
	body_test_params.motion = step_up
	PhysicsServer3D.body_test_motion(self.get_rid(), body_test_params, body_test_result)
	test_transform = test_transform.translated(body_test_result.get_travel())

	# 3. Move test_transform forward by remaining distance
	body_test_params.from = test_transform
	body_test_params.motion = remainder
	PhysicsServer3D.body_test_motion(self.get_rid(), body_test_params, body_test_result)
	test_transform = test_transform.translated(body_test_result.get_travel())

	# 3.5 Project remaining along wall normal (if any)
	## So you can walk into wall and up a step
	if body_test_result.get_collision_count() != 0:
		remainder = body_test_result.get_remainder().length()

		### Uh, there may be a better way to calculate this in Godot.
		var wall_normal = body_test_result.get_collision_normal()
		var dot_div_mag = move_direction.dot(wall_normal) / (wall_normal * wall_normal).length()
		var projected_vector = (move_direction - dot_div_mag * wall_normal).normalized()

		body_test_params.from = test_transform
		body_test_params.motion = remainder * projected_vector
		PhysicsServer3D.body_test_motion(self.get_rid(), body_test_params, body_test_result)
		test_transform = test_transform.translated(body_test_result.get_travel())

	# 4. Move test_transform down onto step
	body_test_params.from = test_transform
	body_test_params.motion = MAX_STEP_UP * -vertical

	# Return if no collision
	if !PhysicsServer3D.body_test_motion(self.get_rid(), body_test_params, body_test_result):
		return

	test_transform = test_transform.translated(body_test_result.get_travel())

	# 5. Check floor normal for un-walkable slope
	var surface_normal = body_test_result.get_collision_normal()
	if (snappedf(surface_normal.angle_to(vertical), 0.001) > floor_max_angle):
		return

	# 6. Move player up
	var global_pos = global_position

	velocity.y = 0
	global_pos.y = test_transform.origin.y
	global_position = global_pos
