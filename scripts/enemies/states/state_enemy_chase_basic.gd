class_name StateEnemyChaseBasic
extends State

func enter_state():
    pass

func state_physics_process(_delta: float, _parent_character: CharacterBody3D):
    update_velocity_to_player_requested.emit()