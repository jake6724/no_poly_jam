class_name Dentist
extends Node3D

@export var animation_player: AnimationPlayer
@export var idle_timer: Timer

var anims: Array[String] = ["Dentist_IdleA", "Dentist_IdleB", "Dentist_IdleC", "Dentist_IdleD"]

func _ready():
    animation_player.play(anims.pick_random())
    # idle_timer.timeout.connect(on_idle_timer_timeout)

# func on_idle_timer_timeout() -> void:
#     animation_player.play(anims.pick_random())
#     idle_timer.wait_time = randf_range(8, 20)