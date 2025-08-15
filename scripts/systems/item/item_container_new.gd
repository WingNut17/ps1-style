extends Node3D


@export var head: Node3D
@export var camera: Camera3D
@export var item_pos: Marker3D
@export var ammo_label: Label
@export var item_animation: AnimationPlayer
@export var item_audio: AudioStreamPlayer
@export var item: Item

var shoot_mesh


func _ready() -> void:
	equip_item()

func _unhandled_input(event: InputEvent) -> void:
	if item:
		if event.is_action_pressed("click"):
			if item.has_method("on_primary_action") and item.equipable:
				item.on_primary_action(self)
			
			if item.get("full_auto") != null:
				if item.full_auto:
					pass
		
		elif event.is_action_released("click"):
			if item.get("full_auto") != null and item.equipable:
				if item.full_auto:
					pass
		
		elif event.is_action_pressed("reload"):
			if item.has_method("on_reload") and item.equipable:
				item.on_reload(self)

func setup_item() -> void:
	var item_node
	if item and item.equipable:
		item_node = item.item_model.instantiate()
		item_pos.add_child(item_node)
		
		if item is RangedWeaponItem:
			if item_node.get_node_or_null("ShootMesh"):
				shoot_mesh = item_node.get_node_or_null("ShootMesh")

func equip_item() -> void:
	if item.has_method("on_item_equip"):
		item.on_item_equip(self)
		setup_item()

func _on_inventory_equip_item(item_resource: Item) -> void:
	if item == item_resource:
		return
	
	item = item_resource
	equip_item()
