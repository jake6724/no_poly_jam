class_name Ghost
extends CharacterBody3D

@export var animation_player: AnimationPlayer
@export var player: Player
@export var move_speed_min: float = 7.0
@export var move_speed_max: float = 13.0
@export var mesh: MeshInstance3D
@export var damage: float = 30.0
@export var attack_area: Area3D
var move_speed: float
var acceleration: float = 13

func _ready():
	animation_player.play("Ghost_Idle")
	move_speed = randf_range(move_speed_min, move_speed_max)
	attack_area.body_entered.connect(on_attack_area_body_entered)
	# move_speed = 11

func _physics_process(delta):
	move_toward_player(delta)

func move_toward_player(delta) -> void:
	var direction: Vector3 = global_position.direction_to(player.global_position)
	velocity = velocity.move_toward((move_speed * direction), acceleration * delta)
	look_at((player.global_transform.origin), Vector3.UP, true)
	move_and_slide()

func on_attack_area_body_entered(player: Player) -> void:
	player.take_damage(damage)
