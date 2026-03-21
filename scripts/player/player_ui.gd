class_name PlayerUI
extends CanvasLayer

@export var scrap_value: Label
@export var steel_value: Label
@export var titanium_value: Label
@export var healthbar: ProgressBar
@export var banner: Label

func _ready():
	update()
	PlayerInventory.update_path_index_updated.connect(update)
	banner.hide()

func update() -> void:
	scrap_value.text = str(PlayerInventory.player_currency[PlayerInventory.Currency.SCRAP])
	steel_value.text = str(PlayerInventory.player_currency[PlayerInventory.Currency.STEEL])
	titanium_value.text = str(PlayerInventory.player_currency[PlayerInventory.Currency.TITANIUM])

func update_health(_value: float) -> void:
	healthbar.value = _value

func fade_banner() -> void:
	banner.show()
	await get_tree().create_timer(5).timeout
	var tween = get_tree().create_tween()
	tween.tween_property(banner, "modulate:a", 0, 3)
