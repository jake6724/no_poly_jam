class_name Upgrade
extends Interactable

const ROTATION_SPEED_MULTIPLIER: float = 1.2

@export var mesh: MeshInstance3D
@export var index: int = 0
@export var desc_sprite: Sprite3D
@export var desc_label: Label
@export var hint_sprite: Sprite3D
@export var hint_label: Label
@export var rotate_parent: Node3D

@export var upgrade_run: MeshInstance3D
@export var upgrade_speed: MeshInstance3D
@export var upgrade_pierce: MeshInstance3D
@export var upgrade_tongue: MeshInstance3D
@export var upgrade_damage: MeshInstance3D
@export var upgrade_jump: MeshInstance3D
@export var upgrade_slide: MeshInstance3D

func _ready():
	set_labels()
	PlayerInventory.update_path_index_updated.connect(set_labels)

func _process(delta):
	rotate_parent.rotation.y += (delta * ROTATION_SPEED_MULTIPLIER)

func set_labels() -> void:
	var upgrade_data: Array = PlayerInventory.upgrade_paths[index]
	var upgrade_data_index: int = PlayerInventory.upgrade_path_indexes[index]

	if upgrade_data_index > 2:
		hide()
		can_interact = false
		return

	var current_tier_upgrade_data: Array = upgrade_data[upgrade_data_index]

	desc_label.text = str(current_tier_upgrade_data[2])
	hint_label.text = PlayerInventory.upgrade_hint[upgrade_data_index]

	set_icon(current_tier_upgrade_data[0])

func set_icon(_stat: PlayerInventory.Stat) -> void:
	upgrade_run.hide()
	upgrade_speed.hide()
	upgrade_pierce.hide()
	upgrade_tongue.hide()
	upgrade_damage.hide()
	upgrade_jump.hide()
	upgrade_slide.hide()
	
	match _stat: 
		PlayerInventory.Stat.MOVE_SPEED: upgrade_run.show()
		PlayerInventory.Stat.MAX_SPEED: upgrade_speed.show()
		PlayerInventory.Stat.SLIDE_PIERCE_MAX: upgrade_pierce.show()
		PlayerInventory.Stat.GRAPPLE_DISTANCE: upgrade_tongue.show()
		PlayerInventory.Stat.DAMAGE: upgrade_damage.show()
		PlayerInventory.Stat.JUMP_POWER: upgrade_jump.show()
		PlayerInventory.Stat.SLIDE_POWER: upgrade_slide.show()

func interact() -> void:
	if can_interact:
		if PlayerInventory.can_purchase_upgrade(index):
			PlayerInventory.purchase_upgrade(index) 
