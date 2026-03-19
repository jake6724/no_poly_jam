class_name RexSkin
extends Node3D

@export var animation_tree: AnimationTree
@onready var state_machine: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/StateMachine/playback")
@export var animation_player: AnimationPlayer
@export var skeleton: Skeleton3D
@export var tongue: Node3D

var player_velocity: Vector3
var player_input: Vector2
var player_is_grounded: bool
var player_is_sliding: bool = false
var player_is_sprinting: bool = false
var vector_3_zero: Vector3 = Vector3.ZERO

signal bite_finished
signal bite_collider_requested

func _ready():
	animation_tree.animation_finished.connect(on_animation_tree_animation_finished)
	skeleton.set_bone_pose(39, Transform3D())
	animation_tree.active = true

func _process(_delta):
	animation_tree.set("parameters/StateMachine/Move/blend_position", player_input)
	animation_tree.set("parameters/StateMachine/SpZ:rintMove/blend_position", player_input)

func bite():
	animation_tree["parameters/BiteOneShot/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE

func slide():
	animation_tree["parameters/SlideOneShot/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE

func stop_slide():
	animation_tree.set("parameters/SlideOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FADE_OUT)

func bite_audio() -> void:
	AudioManager.create_3d_audio_at_location(global_position, SoundEffect.SOUND_EFFECT_TYPE.BITE)

func request_bite_collider(_value: bool) -> void:
	bite_collider_requested.emit(_value)

func on_animation_tree_animation_finished(_anim_name: String) -> void:
	if _anim_name == "Rex_Bite":
		bite_finished.emit()

func footstep_audio() -> void:
	AudioManager.create_3d_audio_at_location(global_position, SoundEffect.SOUND_EFFECT_TYPE.FOOTSTEP)

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
