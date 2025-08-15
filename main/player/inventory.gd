extends Node


@export var inventory_list: Array[Item] = [
	preload("res://resources/items/pistol_ammo.tres"),
	preload("res://resources/items/weapons/glock_19.tres")
]

func add_item(item_resource: Item) -> void:
	inventory_list.append(item_resource)

func remove_item(item_resource: Item) -> void:
	inventory_list.erase(item_resource)

func get_ammo_count(ammo_type: String) -> int:
	var total = 0
	for item in inventory_list:
		if item is AmmoItem and item.ammo_type == ammo_type:
			total += item.ammo_count
	return total

func remove_ammo(ammo_type: String, amount: int) -> void:
	var remaining = amount
	for item in inventory_list:
		if item is AmmoItem and item.ammo_type == ammo_type:
			var used = min(item.ammo_count, remaining)
			item.ammo_count -= used
			remaining -= used
			if item.ammo_count <= 0:
				remove_item(item)
			if remaining <= 0:
				break
