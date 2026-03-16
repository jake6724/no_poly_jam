class_name RexSkin
extends Node3D

@export var animation_tree: AnimationTree
@onready var state_machine: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/StateMachine/playback")
@export var animation_player: AnimationPlayer

var player_velocity: Vector3
var player_input: Vector2
var player_is_grounded: bool
var vector_3_zero: Vector3 = Vector3.ZERO


func _process(_delta):
	print(player_input)
	animation_tree.set("parameters/StateMachine/Move/blend_position", player_input)

func idle():
	pass
	# state_machine.travel("Idle")

func move():
	pass
	# state_machine.travel("Move")

func fall():
	pass
	# state_machine.travel("Fall")

func jump():
	pass
	# state_machine.travel("Jump")
