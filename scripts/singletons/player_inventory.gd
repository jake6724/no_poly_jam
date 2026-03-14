extends Node

enum Currency {SCRAP, STEEL, TITANIUM, BLOOD}

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