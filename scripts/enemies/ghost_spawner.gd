class_name GhostSpawner
extends Node3D

@export var player: Player
var spawn_timer: Timer = Timer.new()
var initial_spawn_delay_min: float = 60.0
var initial_spawn_delay_max: float = 90.0
var spawn_delay: float = 30.0
var spawn_delay_decrement: float = 2.0

const GHOST_SCENE: PackedScene = preload("res://scenes/Enemy/Ghost.tscn")

func _ready():
    spawn_timer.one_shot = true
    spawn_timer.autostart = false
    add_child(spawn_timer)
    spawn_timer.timeout.connect(on_spawn_timer_timeout)
    spawn_timer.start(randf_range(initial_spawn_delay_min, initial_spawn_delay_max))

func spawn_ghost() -> void:
    var new_ghost: Ghost = GHOST_SCENE.instantiate()
    new_ghost.player = player
    add_child(new_ghost)
    new_ghost.global_position = global_position
    AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.GHOST_SPAWN)

func on_spawn_timer_timeout() -> void:
    spawn_ghost()
    spawn_timer.start(spawn_delay)
    spawn_delay -= spawn_delay_decrement