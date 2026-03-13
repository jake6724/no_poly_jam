class_name PlayerUI
extends CanvasLayer

@export var scrap_value: Label
@export var steel_value: Label
@export var titanium_value: Label
@export var blood_value: Label

func _ready():
    scrap_value.text = str(PlayerInventory.scrap)
    steel_value.text = str(PlayerInventory.steel)
    titanium_value.text = str(PlayerInventory.titanium)
    blood_value.text = str(PlayerInventory.blood)