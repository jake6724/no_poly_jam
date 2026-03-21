extends CanvasLayer

@export var settings_menu: SettingsMenu
@export var resume_button: Button
@export var settings_button: Button
@export var exit_button: Button
@export var back_button: Button
@export var how_to_play_button: Button
@export var how_to: TextureRect
var can_pause: bool = false

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()

	resume_button.pressed.connect(on_resume_button_pressed)
	exit_button.pressed.connect(on_exit_button_pressed)
	back_button.pressed.connect(on_back_button_pressed)
	how_to_play_button.pressed.connect(on_how_to_play_button_pressed)

func _input(_event):
	if can_pause:
		if Input.is_action_just_pressed("escape"):
			if get_tree().paused:
				get_tree().paused = false
				hide()
			else:
				get_tree().paused = true
				show()

func on_resume_button_pressed() -> void:
	get_tree().paused = false
	hide()

func on_back_button_pressed() -> void:
	how_to.hide()

func on_exit_button_pressed() -> void:
	pass

func on_how_to_play_button_pressed() -> void:
	how_to.show()
