extends Node

var font: FontFile = preload("res://fonts/Domine-VariableFont_wght.ttf")

func spawn_popup(spawn_position: Vector3, value: Variant, is_text: bool=false, font_size:int=48, follow_target:Node3D=null) -> void:
	var popup: Label3D = Label3D.new()
	if is_text:
		popup.text = value
	else:
		popup.text = str(int(value))
	
	popup.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	popup.font_size = font_size
	popup.outline_size = 16
	popup.font = font
	popup.modulate = Color.WHITE
	popup.outline_modulate = Color.BLACK

	if follow_target:
		follow_target.add_child(popup)
		await get_tree().create_timer(1.4).timeout
		popup.queue_free()
	else:
		call_deferred("add_child", popup)
		await popup.ready
		popup.global_position = spawn_position

		var tween = get_tree().create_tween()
		tween.tween_property(popup, "position:y", popup.position.y + .7, .7) 
		tween.tween_interval(.7)
		tween.tween_property(popup, "scale", Vector3(.1,.1,.1), .1)
		await tween.finished
		popup.queue_free()