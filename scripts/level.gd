class_name Level
extends Node3D

@export var player: Player
@export var player_spawn_points: Node

func _ready():
    # Spawn player at a random spawn point
    var enabled_spawn_points: Array = []
    for child in player_spawn_points.get_children():
        var player_spawn_point: PlayerSpawnPoint = child as PlayerSpawnPoint
        if player_spawn_point.enabled:
            enabled_spawn_points.append(player_spawn_point)

    player.global_position = enabled_spawn_points.pick_random().global_position
    for child in player_spawn_points.get_children():
        child.hide()