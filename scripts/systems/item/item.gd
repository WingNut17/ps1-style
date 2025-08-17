class_name Item
extends Resource


var item_container: Node3D

@export_category("identification")
@export var equipable: bool = true
@export var consumable: bool = false
@export var item_name: String
@export_multiline var item_description: String
@export var item_model: PackedScene
@export var item_thumbnail: Texture2D


func initialize(holder: Node3D) -> void:
	item_container = holder

func on_item_equip() -> void:
	item_container.item_animation.play("equip")
