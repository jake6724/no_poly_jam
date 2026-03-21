extends CanvasLayer
# SceneTransition is a scene singleton, this is just the script attached to it

@export var transition: ColorRect

var shader: ShaderMaterial

var shader_progress_target: float = 3.0
var progress_sign: float = 1.0
const PROGRESS_SPEED_MULTIPLIER: float = 1.5

var is_transit_out: bool = false

const MALL_LEVEL: PackedScene = preload("res://scenes/Environment/LevelMall.tscn")
const DENTIST_LEVEL: PackedScene = preload("res://scenes/Environment/LevelDentist.tscn")
const MAIN_MENU_LEVEL: PackedScene = preload("res://scenes/MainMenu.tscn")
var target_scene = DENTIST_LEVEL

# func _input(event):
#     if Input.is_action_just_pressed("x"):
#         print("Trigger")
#         transition_out()

func _ready():
	shader = transition.material as ShaderMaterial
	set_process(false)

func _process(delta):
	var shader_progress: float = shader.get_shader_parameter("progress")
	shader_progress += (delta * PROGRESS_SPEED_MULTIPLIER * progress_sign)
	shader.set_shader_parameter("progress", shader_progress)

	if is_transit_out and shader_progress >= shader_progress_target:
		set_process(false)
		get_tree().change_scene_to_packed(target_scene)
		transition_in()

	elif not is_transit_out and shader_progress <= shader_progress_target:
		set_process(false)
	
func transition_out() -> void:
	ZombieManager.clear_all_zombies()
	is_transit_out = true
	progress_sign = 1.0
	shader_progress_target = 3.0
	set_process(true)

func transition_in() -> void:
	is_transit_out = false
	progress_sign = -1.0
	shader_progress_target = 0.0
	set_process(true)
