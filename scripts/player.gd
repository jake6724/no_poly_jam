class_name Player
extends CharacterBody3D

# https://github.com/godotengine/godot/issues/69771
# Spring arm behavior is weird when close to wall geomertry. Can fix this mostly by leaving shape empty for the spring arm
# This will make it take on the shape of the camera which I guess fixes it

@export_group("Player Settings")
@export_range(0, 1.0) var mouse_sensitivty: float = 0.25
@export var rotation_speed: float = 12.0
@export_range(1, 20, 1) var zoom_sensitivity: float = .5
@export_range(.1, 10, .1) var zoom_step: float = 1
@export_range(3, 10, 1) var zoom_min: float = 3
@export_range(5, 20, 1) var zoom_max: float = 10
@export var right_click_to_rotate_camera: bool = false
@export_group("Movement")
@export var move_speed: float = 8.0
@export var move_speed_sprint: float = 10.0
var move_speed_base: float 
@export_range(20,100,1) var acceleration: float = 20.0
@export var jump_power: float = 12.0
@export_range(0,1,.1) var jump_coyote_time: float = 0.5
@export var gravity: float = -30

@export var _camera: Camera3D
@export var _camera_pivot: Node3D
@export var _spring_arm: SpringArm3D
var _camera_input_direction: Vector2 = Vector2.ZERO
var _last_movement_direction: Vector3 = Vector3.BACK
var _rotate_camera: bool = false

@export var grapple_raycast: RayCast3D
@export var grapple_controller: GrappleController

var zoom_target: float

const MOVE_DIRECTION_THRESHOLD: float = 0.2

@export var _skin: Node3D

var coyote_jump_available: bool = true
var coyote_jump_timer: Timer = Timer.new()
var prev_is_on_floor: bool = true

func _ready():
	zoom_target = _spring_arm.spring_length 
	move_speed_base = move_speed
	coyote_jump_timer.one_shot = true
	coyote_jump_timer.autostart = false
	add_child(coyote_jump_timer)
	coyote_jump_timer.timeout.connect(on_coyote_jump_timer_timeout)
	_rotate_camera = not right_click_to_rotate_camera

func _process(delta):
	if not is_equal_approx(_spring_arm.spring_length, zoom_target):
		zoom_target = clamp(zoom_target, zoom_min, zoom_max)
		_spring_arm.spring_length = lerp(_spring_arm.spring_length, zoom_target, zoom_sensitivity * delta)

func _input(_event):
	if Input.is_action_just_pressed("left_click"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if Input.is_action_just_pressed("escape"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if Input.is_action_just_pressed("sprint"):
		move_speed = move_speed_sprint
		_skin.animation_tree.set("parameters/TimeScale/scale", 1.25)
	if Input.is_action_just_released("sprint"):
		move_speed = move_speed_base
		_skin.animation_tree.set("parameters/TimeScale/scale", 1.0)
	if Input.is_action_just_pressed("jump"):
		jump()
	if right_click_to_rotate_camera:
		if Input.is_action_just_pressed("right_click"):
			_rotate_camera = true
		if Input.is_action_just_released("right_click"):
			_rotate_camera = false
	# if Input.is_action_just_pressed("respawn"):
	# 	global_ = Vector3(0,0,0)

func _unhandled_input(event: InputEvent) -> void:
	# Check mouse has moved
	var is_camera_motion: bool = (event is InputEventMouseMotion) and (Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED)
	if is_camera_motion:
		_camera_input_direction = event.screen_relative * mouse_sensitivty

	if Input.is_action_just_pressed("scroll_up"):
		zoom_target -= zoom_step
	if Input.is_action_just_pressed("scroll_down"):
		zoom_target += zoom_step

func _physics_process(delta: float) -> void:
	# print(velocity)	
	if _rotate_camera:
		# Set X and Y camera rotation. Clamp X axis so player cannot look fully up or down
		_camera_pivot.rotation.x += _camera_input_direction.y * delta
		_camera_pivot.rotation.y -= _camera_input_direction.x  * delta
		_camera_pivot.rotation.x = clamp(_camera_pivot.rotation.x, (-PI / 6.0), (PI / 3.0))

	# Reset _camera_input_direction for the next time _unhandled_input() is triggered
	# If this is not reset, the camera will keep rotating until new input comes in
	_camera_input_direction = Vector2.ZERO

	# Get the raw 2-axis input data, forward direction of camera, and right direction of camera
	# Forward direction is used to move back-and-forth, right direction is used to move left-and-right
	var raw_input: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var forward_direction: Vector3 = _camera.global_basis.z
	var right_direction: Vector3 = _camera.global_basis.x

	# Final move direction is the sum of back-and-forth and left-and-right movement
	var move_direction: Vector3 = (forward_direction * raw_input.y) + (right_direction * raw_input.x)
	move_direction.y = 0.0 # Player will never give up-and-down move input. Jumping and falling with handle this
	move_direction = move_direction.normalized() # This is just intended to be a direction vector so it needs to be normalized

	# Acceleration can be added by using move_toward(). This will also prevent overshooting inheritly
	var y_velocity = velocity.y
	velocity.y = 0.0
	velocity = velocity.move_toward(move_direction * move_speed, acceleration * delta)
	velocity.y = (y_velocity + (gravity * delta))

	if prev_is_on_floor != is_on_floor() and not is_on_floor():
		coyote_jump_timer.start(jump_coyote_time)

	prev_is_on_floor = is_on_floor()

	move_and_slide()

	# Ensure that character look direction does not update when there is no input
	if move_direction.length() > MOVE_DIRECTION_THRESHOLD:
		_last_movement_direction = move_direction

	var target_angle: float = Vector3.BACK.signed_angle_to(_last_movement_direction, Vector3.UP)
	_skin.global_rotation.y = lerp_angle(_skin.global_rotation.y, target_angle, rotation_speed * delta)

	# Animate
	if not is_on_floor() and velocity.y <= 0:
		_skin.fall()
		
	elif is_on_floor():
		coyote_jump_available = true
		coyote_jump_timer.stop()
		var ground_speed: float = velocity.length()
		if ground_speed > 1.0:
			_skin.move()
		else:
			_skin.idle()

func jump() -> void:
	if is_on_floor() or grapple_controller.launched or coyote_jump_available:
		grapple_controller.launched = false
		coyote_jump_available = false
		velocity.y = jump_power
		_skin.jump()

func on_coyote_jump_timer_timeout() -> void:
	coyote_jump_available = false
