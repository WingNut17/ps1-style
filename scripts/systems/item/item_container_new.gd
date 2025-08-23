class_name ItemContainer
extends Node3D


@export var head: Node3D
@export var camera: Camera3D
@export var item_pos: Marker3D
@export var ammo_label: Label
@export var item_animation: AnimationPlayer
@export var item_audio: AudioStreamPlayer
@export var primary_timer: Timer
@export var secondary_timer: Timer
@export var item: Item

var item_node: Node3D
var current_recoil: Vector3 = Vector3.ZERO
var default_position: Vector3
var default_rotation: Vector3


func _ready() -> void:
	default_position = item_pos.position
	default_rotation = item_pos.rotation_degrees
	if item:
		setup_item()

func _process(delta: float) -> void:
	camera.rotation_degrees = camera.rotation_degrees.lerp(Vector3.ZERO, delta * 2.0)
	item_pos.rotation_degrees = item_pos.rotation_degrees.lerp(default_rotation, delta * 4.0)
	item_pos.position = item_pos.position.lerp(default_position, delta * 2.0)

func setup_item() -> void:
	if !item or !item.equipable:
		return
	
	item_node = item.item_model.instantiate()
	
	for child in item_pos.get_children():
		if not child is Marker3D:
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
