class_name GrappleController
extends Node

@export var player: Player
@export var grapple_raycast: RayCast3D
@export var rest_length: float = 2.0
@export var stiffness: float = 10.0 # higher the stiffness, faster spring will retract
@export var damping_power: float = -1.0 
@export var grapple_rope: Node3D

var launched: bool = false
var target: Vector3

func _physics_process(delta) -> void:
    if Input.is_action_just_pressed("left_click"):
        launch()
    if Input.is_action_just_released("left_click"):
        retract()

    if launched:
        handle_grapple(delta)

    update_rope()

func launch() -> void:
    if grapple_raycast.is_colliding():
        target = grapple_raycast.get_collision_point()
        launched = true
        player._skin.jump()

func retract() -> void:
    launched = false

func handle_grapple(delta: float) -> void:
    var target_direction: Vector3 = player.global_position.direction_to(target)
    var target_distance: float = player.global_position.distance_to(target)

    var displacement: float = target_distance - rest_length

    var force: Vector3 = Vector3.ZERO

    if displacement > 0: # spring is stretched, pull player with it

        # SFM is how strong the spring is this time
        var spring_force_magnitude: float = stiffness * displacement 
        # Spring force is what we'll actually apply (direction * magnitude)
        var spring_force: Vector3 = target_direction * spring_force_magnitude

        var velocity_dot: float = player.velocity.dot(target_direction)
        var damping = -damping_power * velocity_dot * target_direction


        print("spring_force: ", spring_force)  
        print("damping: ", damping)
        force = spring_force + damping

    print("force: ", force)

    print("force * delta = ", (force * delta))
    player.velocity += (force * delta)

func update_rope() -> void:
    if not launched:
        grapple_rope.hide()
        return

    grapple_rope.show()
    var grapple_rope_length = player.global_position.distance_to(target)
    grapple_rope.look_at(target)
    grapple_rope.scale = Vector3(1,1,grapple_rope_length)