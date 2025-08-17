extends Node3D


@export var head: Node3D
@export var camera: Camera3D
@export var item_pos: Marker3D
@export var ammo_label: Label
@export var item_animation: AnimationPlayer
@export var item_audio: AudioStreamPlayer
@export var full_auto_timer: Timer
@export var item: Item

var shoot_mesh


func _ready() -> void:
	if item:
		setup_item()

func _unhandled_input(event: InputEvent) -> void:
	if !item or !item.equipable:
		return
	
	if event.is_action_pressed("click"):
		if item.get("full_auto") != null:
			if item.full_auto:
				item.on_full_auto_start()  # Start full auto
			else:
				item.on_primary_action()   # Single shot
		elif item.has_method("on_primary_action"):
			item.on_primary_action()
	
	elif event.is_action_released("click"):
		if item.get("full_auto") != null:
			if item.full_auto:
				item.on_full_auto_stop()   # Stop full auto
	
	elif event.is_action_pressed("reload"):
		if item.has_method("on_reload"):
			item.on_reload()

func setup_item() -> void:
	var item_node
	if !item or !item.equipable:
		return
	
	item_node = item.item_model.instantiate()
	
	for child in item_pos.get_children():
		child.queue_free()
	
	item_pos.add_child(item_node)
	item.initialize(self)
	
	if item.has_method("on_item_equip"):
		item.on_item_equip()
	
	if item is RangedWeaponItem:
		ammo_label.visible = true
		
		if item.update_ammo.is_connected(_update_ammo):
			item.update_ammo.disconnect(_update_ammo)
		item.update_ammo.connect(_update_ammo)
		_update_ammo()
		
		if item_node.get_node_or_null("ShootMesh"):
			shoot_mesh = item_node.get_node_or_null("ShootMesh")
	else:
		ammo_label.visible = false

func _update_ammo() -> void:
	if item is RangedWeaponItem:
		ammo_label.text = str("ammo: ", item.magazine_ammo, "/", Inventory.get_ammo_count(item.ammo_type))

func _on_inventory_equip_item(item_resource: Item) -> void:
	if item == item_resource:
		return
	
	item = item_resource
	setup_item()
