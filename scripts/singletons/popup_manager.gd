extends Node

var font: FontFile = preload("res://fonts/Domine-VariableFont_wght.ttf")

func spawn_popup(spawn_position: Vector3, value: float) -> void:
	var popup: Label3D = Label3D.new()
	popup.text = str(int(value))
	
	popup.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	popup.font_size = 48
	popup.outline_size = 16
	popup.font = font
	popup.modulate = Color.WHITE
	popup.outline_modulate = Color.BLACK

	call_deferred("add_child", popup)
	await popup.ready
	popup.global_position = spawn_position

	var tween = get_tree().create_tween()
	tween.tween_property(popup, "position:y", popup.position.y + .7, .7) 
	tween.tween_interval(.7)
	tween.tween_property(popup, "scale", Vector3(.1,.1,.1), .1)
	await tween.finished
	popup.queue_free()