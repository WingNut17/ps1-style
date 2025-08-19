class_name Item
extends Resource


var item_container: Node3D

@export_category("identification")
@export var equipable: bool = true
@export var consumable: bool = false
@export var pull_out_time: float = 2.0
@export var item_name: String
@export_multiline var item_description: String
@export var item_model: PackedScene
@export var item_thumbnail: Texture2D


func initialize(holder: Node3D) -> void:
	item_container = holder

func on_item_equip() -> void:
	if pull_out_time:
		item_container.item_animation.speed_scale = 1/pull_out_time
	item_container.item_animation.play("equip")
