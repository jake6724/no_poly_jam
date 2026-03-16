
class_name Extract
extends Interactable

@export var countdown_sprite: Sprite3D
@export var countdown_label: Label
@export var interact_sprite: Sprite3D

signal extract_started
signal extract_ready

var is_extract_started: bool = false
var countdown_timer: Timer = Timer.new()

const COUNTDOWN_DURATION: float = 30.0

func _ready():
    set_process(false)

    countdown_timer.one_shot = true
    countdown_timer.autostart = false
    add_child(countdown_timer)
    countdown_timer.timeout.connect(on_countdown_timer_timeout)

func interact() -> void:
    if not is_extract_started and can_interact:
        can_interact = false
        is_extract_started = true
        hide_interact_hint()

        print("Starting Extract")
        countdown_sprite.show()
        countdown_timer.start(COUNTDOWN_DURATION)
        set_process(true)

func _process(_delta):
    var time: float = snappedf(countdown_timer.time_left, .1)
    countdown_label.text = str(time)

func on_countdown_timer_timeout() -> void:
    set_process(false)
    countdown_label.text = "Ready to Extract!"