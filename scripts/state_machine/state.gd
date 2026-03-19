class_name State
extends Node

var parent_character: CharacterBody3D # Set by StateMachine

var state_name: String # Set by statemachine

var animation_1: String
var animation_2: String
var animation_3: String
signal transition_state
signal update_velocity_requested
signal update_move_target_to_prey_requested
signal update_patrol_position_requested
signal update_move_target_to_patrol_position_requested
signal attack_requested

func init_state():
	pass

func enter_state():
	pass

func process_state(_delta):
	pass

func state_physics_process(_delta, _parent_character: CharacterBody3D):
	pass

func exit_state():
	pass