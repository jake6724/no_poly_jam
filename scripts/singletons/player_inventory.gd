extends Node

enum Currency {SCRAP, STEEL, TITANIUM, BLOOD}
enum Stat {MOVE_SPEED, MAX_SPEED, SLIDE_PIERCE_MAX, GRAPPLE_DISTANCE, DAMAGE, JUMP_POWER, SLIDE_POWER}

var is_first_time: bool = true

var player_currency: Dictionary[Currency, int] = {
	Currency.SCRAP: 0,
	Currency.STEEL: 0,
	Currency.TITANIUM: 0,
	Currency.BLOOD: 0,
}

var currency_spawn_chance_array_metal = [
	[Currency.SCRAP, 70],
	[Currency.STEEL, 20],
	[Currency.TITANIUM, 10],
]

var currency_materials: Dictionary[Currency, StandardMaterial3D] = {
	Currency.SCRAP: preload("res://materials/pickup/material_pickup_scrap.tres"),
	Currency.STEEL: preload("res://materials/pickup/material_pickup_steel.tres"),
	Currency.TITANIUM: preload("res://materials/pickup/material_pickup_titanium.tres"),
}

var move_speed_walk: float = 5
var move_speed_sprint: float = 10.0
var max_speed: float = 50.0
var slide_pierce_max: int = 20.0
var slide_power: float = 23.0
var jump_power: float = 12.0
var damage: float = 25.0
var grapple_distance: float = 60.0

var upgrade_path_1_index: int = 0
var upgrade_path_2_index: int = 0
var upgrade_path_3_index: int = 0

var upgrade_paths: Array = []

var upgrade_path_indexes: Array = []

var upgrade_path_1: Array = [
	[Stat.SLIDE_POWER, 0.5, "Increase slide boost by +50%"],
	[Stat.JUMP_POWER, 0.5, "Increase jump power by +50%"],
 	[Stat.MOVE_SPEED, 0.5, "Increase move speed by +50%"],
]

var upgrade_path_2: Array = [
	[Stat.SLIDE_PIERCE_MAX, 1.0, "Increase max slide combo by +100%"],
	[Stat.GRAPPLE_DISTANCE, 1.0, "Increase grapple range by +100%"],
	[Stat.DAMAGE, 0.5, "Increase damage by +50%"],
	]

var upgrade_path_3: Array = [
	[Stat.MAX_SPEED, 1.0, "Increase max speed by +100%"],
	[Stat.DAMAGE, 0.5, "Increase damage by +50%"],
	[Stat.SLIDE_PIERCE_MAX, 1.0, "Increase max slide combo by +100%"],
]

var upgrade_hint = [
	"[E] x10 Coins",
	"[E] x2 Coins, x3 Gems",
	"[E] x1 Coin, x2 Gems, x3 Crystals"
]

var upgrade_cost = [
	[10, 0, 0],
	[2, 3, 0],
	[1, 2, 3],
]

signal update_path_index_updated

func can_purchase_upgrade(_index: int) -> bool:
	if _index <= 2:
		var upgrade_data_index: int = upgrade_path_indexes[_index]
		var tier_cost_data: Array = upgrade_cost[upgrade_data_index]
		if player_currency[Currency.SCRAP] >= tier_cost_data[0]:
			if player_currency[Currency.STEEL] >= tier_cost_data[1]:
				if player_currency[Currency.TITANIUM] >= tier_cost_data[2]:
					player_currency[Currency.SCRAP] -= tier_cost_data[0]
					player_currency[Currency.STEEL] -= tier_cost_data[1]
					player_currency[Currency.TITANIUM] -= tier_cost_data[2]
					return true
	return false

func purchase_upgrade(_index: int) -> void:
	var upgrade_data: Array = upgrade_paths[_index]
	var upgrade_data_index: int = upgrade_path_indexes[_index]
	var current_tier_upgrade_data: Array = upgrade_data[upgrade_data_index]
	set_player_stat(current_tier_upgrade_data[0], current_tier_upgrade_data[1])

	upgrade_path_indexes[_index] += 1
	update_path_index_updated.emit()

	AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.PURCHASE)

func _ready():
	upgrade_paths = [upgrade_path_1, upgrade_path_2, upgrade_path_3]
	upgrade_path_indexes = [upgrade_path_1_index, upgrade_path_2_index, upgrade_path_3_index,]

func set_player_stat(stat: Stat, increase_percent: float):
	match stat:
		Stat.MOVE_SPEED: 
			move_speed_walk = move_speed_walk + (move_speed_walk * (1 + increase_percent))
			move_speed_sprint = move_speed_sprint + (move_speed_sprint * (1 + increase_percent))
		Stat.MAX_SPEED: 
			max_speed = max_speed + (max_speed * (1 + increase_percent))
		Stat.SLIDE_PIERCE_MAX:
			slide_pierce_max = slide_pierce_max + (slide_pierce_max * (1 + increase_percent))
		Stat.GRAPPLE_DISTANCE: 
			grapple_distance = grapple_distance + (grapple_distance * (1 + increase_percent))
		Stat.DAMAGE:
			damage = damage + (damage * (1 + increase_percent))
		Stat.JUMP_POWER: 
			jump_power = jump_power + (jump_power * (1 + increase_percent))
		Stat.SLIDE_POWER: 
			slide_power = slide_power + (slide_power * (1 + increase_percent))
		_: pass

func add_currency(_currency: Currency) -> void:
	player_currency[_currency] += 1

func get_weighted_random_metal_currency() -> Currency:
	return get_weighted_random(currency_spawn_chance_array_metal)

## `spawn_chance_array` must be a doubly-nested array. 
## Each sub-array must contain a value to return, and the chance of getting it.
func get_weighted_random(spawn_chance_array) -> Variant:
	var total = 0
	for i in range(len(spawn_chance_array)):
		total += spawn_chance_array[i][1]

	var r = randf() * total

	for i in range(0, len(spawn_chance_array)):
		var selection = spawn_chance_array[i]
		if r < selection[1]:
			return selection[0]
		r -= selection[1]

	push_error("get_weighted_random reached final return, which should not be possible")
	return # Only here to allow for typed return signature. Should never return here
