class_name InventoryUI
extends Control


signal equip_item(item_resource: Item)
signal use_item(item_resource: Item)

@onready var inventory_item_list: ItemList = %Inventory
@onready var item_description: RichTextLabel = %ItemDescription

@onready var item_select: PanelContainer = %ItemSelect
@onready var use_button: Button = %UseButton
@onready var equip_button: Button = %EquipButton

@onready var exit_button: Button = %ExitButton

var item_resource: Item = null
var item_select_position: Vector2


func _ready() -> void:
	refresh_inventory()
	item_select.pivot_offset = Vector2.ZERO

func _on_visibility_changed() -> void:
	if visible:
		AudioServer.set_bus_effect_enabled(2, 1, true)
	else:
		AudioServer.set_bus_effect_enabled(2, 1, false)
	if inventory_item_list:
		refresh_inventory()

func refresh_inventory() -> void:
	var inventory = Inventory.inventory_list
	
	inventory_item_list.clear()
	
	for item in inventory:
		inventory_item_list.add_item(item.item_name, item.item_thumbnail, true)
	
	for idx in range(inventory_item_list.item_count):
		inventory_item_list.set_item_tooltip_enabled(idx, false)
		
	if item_select.visible:
		item_select.visible = !item_select.visible

func _on_inventory_item_selected(index: int) -> void:
	var item_name := inventory_item_list.get_item_text(index)
	
	for item in Inventory.inventory_list:
		if item.item_name == item_name:
			item_resource = item
			break

	if item_resource:
		item_description.text = item_resource.item_description
	
	if item_select.visible:
		item_select.visible = !item_select.visible

func _on_inventory_empty_clicked(_at_position: Vector2, _mouse_button_index: int) -> void:
	if item_select.visible:
		item_select.visible = !item_select.visible

func _on_inventory_item_clicked(_index: int, at_position: Vector2, _mouse_button_index: int) -> void:
	item_select_position = at_position

func _on_inventory_item_activated(index: int) -> void:
	var item_rect: Rect2 = inventory_item_list.get_item_rect(index)
	
	"""
	var center_in_list: Vector2 = item_rect.position + (item_rect.size * 0.5)

	var list_global_pos: Vector2 = inventory_item_list.get_global_rect().position
	var center_global: Vector2 = list_global_pos + center_in_list

	var parent_global_pos: Vector2 = self.get_global_rect().position
	var center_in_parent: Vector2 = center_global - parent_global_pos
	
	item_select.position = center_in_parent
	"""
	
	use_button.disabled = !item_resource.consumable
	equip_button.disabled = !item_resource.equipable
	
	item_select.position = item_select_position + item_rect.size
	
	item_select.visible = true

func _on_use_button_pressed() -> void:
	use_item.emit(item_resource)

func _on_equip_button_pressed() -> void:
	equip_item.emit(item_resource)

func _on_back_button_pressed() -> void:
	item_select.visible = !item_select.visible

func _on_exit_button_pressed() -> void:
	if GameState.is_in_menu:
		GameState.close_menu()
	visible = !visible
