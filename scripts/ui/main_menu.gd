extends Node3D


@onready var camera_pivot: Node3D = $CameraPivot
@onready var carousel: Node3D = $Carousel
@onready var item_label: Label = %ItemLabel

var can_move: bool = true
var menu_items: Array[Node]
var item_idx: int = 0


func _ready() -> void:
	menu_items = carousel.get_children()
	select_item(item_idx)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_left"):
		if can_move:
			tween_carousel("left")
	if event.is_action_pressed("ui_right"):
		if can_move:
			tween_carousel("right")
	if event.is_action_pressed("click"):
		perform_menu_action(menu_items[item_idx].name)

func tween_carousel(direction) -> void:
	var tween := get_tree().create_tween()
	var current_rotation := camera_pivot.rotation_degrees
	can_move = false
	
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	
	if direction == "left":
		tween.tween_property(camera_pivot, "rotation_degrees", current_rotation - Vector3(0, 90, 0), 0.5)
		item_idx = (item_idx - 1 + menu_items.size()) % menu_items.size()
	elif direction == "right":
		tween.tween_property(camera_pivot, "rotation_degrees", current_rotation + Vector3(0, 90, 0), 0.5)
		item_idx = (item_idx + 1) % menu_items.size()
	
	tween.connect("finished", _on_tween_finished)
	
	select_item(item_idx)

func select_item(index: int) -> void:
	for i in menu_items.size():
		menu_items[i].item_selected = (i == index)
	
	item_label.text = menu_items[index].name

func _on_tween_finished() -> void:
	can_move = true

func perform_menu_action(menu_item: String) -> void:
	match menu_item:
		"Play":
			pass
		"Settings":
			pass
		"Credits":
			pass
		"Load":
			pass
		_:
			print("No menu action assigned to: ", menu_items)

func _on_left_button_pressed() -> void:
	tween_carousel("left")

func _on_right_button_pressed() -> void:
	tween_carousel("right")
