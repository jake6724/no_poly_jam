extends Control

func _input(event):
    if Input.is_action_just_pressed("jump") and visible:
        hide()

func go() -> void:
    await get_tree().create_timer(3).timeout
    show()
