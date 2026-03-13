class_name Level
extends Node3D

@export var player: Player
@export var player_spawn_points: Node

func _ready():
    # Spawn player at a random spawn point
    player.global_position = player_spawn_points.get_children().pick_random().global_position
    for child in player_spawn_points.get_children():
        child.hide()