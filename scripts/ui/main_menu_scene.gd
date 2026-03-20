class_name MainMenuScene
extends Node3D

@export var rex_skin: RexSkin

var bite_timer: Timer = Timer.new()

var anim_options: Array[String] = ["bite", "slide"]

var min_delay: float = 2
var max_delay: float = 5

func _ready():
    bite_timer.one_shot = true
    bite_timer.autostart = false
    add_child(bite_timer)
    bite_timer.timeout.connect(on_bite_timer_timeout)
    bite_timer.start(randf_range(min_delay, min_delay))

func on_bite_timer_timeout() -> void:
    var anim = anim_options.pick_random()
    match anim:
        "bite": rex_skin.bite()
        "slide": 
            rex_skin.player_is_sliding = true
            await get_tree().create_timer(1).timeout
            rex_skin.player_is_sliding = false
    # rex_skin.bite()
    bite_timer.start(randf_range(min_delay, min_delay))