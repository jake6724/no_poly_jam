class_name PlayerUnitGenerator
extends Node

const SCALING_POOL_SIZE: float = 350.0
const SCALING_DISTRIBUTE_STEP: float = 5.0
const SCALING_VALUE_MIN: float = 1.0
const SCALING_VALUE_MAX: float = 100.0

func create_player_unit_data() -> void:
    var new_data: PlayerUnitData = PlayerUnitData.new()
    pass