class_name Level
extends Node3D

@export var player: Player
@export var player_spawn_points: Node
@export var chest_parent: Node

var chests_to_spawn: int = 5

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

	AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.ABANDONED_MALL_AMBIENCE)

	# Spawn random chest
	var chests = chest_parent.get_children()
	for chest: Chest in chests:
		chest.opened = true
		chest.collider.set_deferred("disabled", true)
		chest.hide() 

	var chests_to_spawn_final = min(chests_to_spawn, chest_parent.get_children().size())

	for i in range(chests_to_spawn_final):
		var chest: Chest = chests.pick_random()
		chest.opened = false
		chest.show()
		chest.collider.set_deferred("disabled", false)
		chests.erase(chest)

	PauseMenu.can_pause = true
