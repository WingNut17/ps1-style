extends Node


@export var inventory_list: Array[Item] = []

func _ready():
	inventory_list = [
		load("res://resources/items/ammo/pistol_ammo.tres"),
		load("res://resources/items/weapons/glock_19.tres"),
		load("res://resources/items/weapons/m4a1.tres"),
		load("res://resources/items/weapons/ak47.tres"),
		load("res://resources/items/weapons/revolver.tres"),
		load("res://resources/items/weapons/desert_eagle.tres"),
		load("res://resources/items/ammo/magnum_ammo.tres"),
		load("res://resources/items/ammo/50cal_ammo.tres"),
		load("res://resources/items/weapons/shotgun.tres"),
		load("res://resources/items/ammo/shotgun_ammo.tres"),
		load("res://resources/items/ammo/ar_ammo.tres"),
		load("res://resources/items/weapons/kitchen_knife.tres")
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
