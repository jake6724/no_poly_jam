class_name PlayerUI
extends CanvasLayer

@export var scrap_value: Label
@export var steel_value: Label
@export var titanium_value: Label
@export var blood_value: Label
@export var healthbar: ProgressBar

func _ready():
	update()
	PlayerInventory.update_path_index_updated.connect(update)

func update() -> void:
	scrap_value.text = str(PlayerInventory.player_currency[PlayerInventory.Currency.SCRAP])
	steel_value.text = str(PlayerInventory.player_currency[PlayerInventory.Currency.STEEL])
	titanium_value.text = str(PlayerInventory.player_currency[PlayerInventory.Currency.TITANIUM])
	blood_value.text = str(PlayerInventory.player_currency[PlayerInventory.Currency.BLOOD])

func update_health(_value: float) -> void:
	healthbar.value = _value