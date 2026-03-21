class_name Upgrade
extends Interactable

const ROTATION_SPEED_MULTIPLIER: float = 1.2

@export var mesh: MeshInstance3D
@export var index: int = 0
@export var desc_sprite: Sprite3D
@export var desc_label: Label
@export var hint_sprite: Sprite3D
@export var hint_label: Label


func _ready():
	set_labels()
	PlayerInventory.update_path_index_updated.connect(set_labels)

func _process(delta):
	mesh.rotation.y += (delta * ROTATION_SPEED_MULTIPLIER)

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

func interact() -> void:
	if can_interact:
		if PlayerInventory.can_purchase_upgrade(index):
			print("TEst")
			# can_interact = false
			PlayerInventory.purchase_upgrade(index) 
