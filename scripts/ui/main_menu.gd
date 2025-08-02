extends Node3D


signal start_game

@export var world: Node
@export var main: Node3D

@onready var camera_pivot: Node3D = $CameraPivot
@onready var carousel: Node3D = $Carousel
@onready var load_carousel: Node3D = $LoadCarousel
@onready var menu_item_button: Button = %MenuItemButton
@onready var back_button: Button = %BackButton
@onready var menu_ui_audio: AudioStreamPlayer = $MenuUiAudio

const PLAYER = preload("res://main/player/player.tscn")
const ROTATION_STEP = 72.0
const TWEEN_DURATION = 0.5

var can_move: bool = true
var menu_items: Array[Node] = []
var item_idx: int = 0
var current_carousel: Node3D


func _ready() -> void:
	current_carousel = carousel
	populate_menu_array(current_carousel)
	select_item(item_idx)

func _input(event: InputEvent) -> void:
	if not can_move:
		return

	if event.is_action_pressed("ui_left"):
		rotate_carousel("left")
	elif event.is_action_pressed("ui_right"):
		rotate_carousel("right")

func populate_menu_array(node: Node3D) -> void:
	menu_items = node.get_children()

func rotate_carousel(direction: String) -> void:
	var tween := get_tree().create_tween()
	var rotation_change := Vector3(0, ROTATION_STEP if direction == "right" else -ROTATION_STEP, 0)
	
	menu_ui_audio.stream = preload("res://assets/audio/sound/ui/menu_move.ogg")
	menu_ui_audio.pitch_scale = randf_range(1.0, 1.2) if direction == "right" else randf_range(0.8, 1.0)
	menu_ui_audio.play()
	
	can_move = false
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(camera_pivot, "rotation_degrees", camera_pivot.rotation_degrees + rotation_change, TWEEN_DURATION)
	tween.connect("finished", _on_tween_finished)

	item_idx = (item_idx + 1) % menu_items.size() if direction == "left" else (item_idx - 1 + menu_items.size()) % menu_items.size()
	select_item(item_idx)

func select_item(index: int) -> void:
	for i in menu_items.size():
		menu_items[i].item_selected = (i == index)
	menu_item_button.text = menu_items[index].name

func _on_tween_finished() -> void:
	can_move = true

func perform_menu_action(menu_item: String) -> void:
	match menu_item:
		"Play":
			start_game.emit()
		"Settings":
			print("Settings")
		"Credits":
			print("Credits")
		"Load":
			open_load_carousel()
		"Exit":
			print("Exit")
		"Load1", "Load2", "Load3", "Load4", "Load5":
			print(menu_item)
		_:
			print("No menu action assigned to: ", menu_item)
	
	menu_ui_audio.stream = preload("res://assets/audio/sound/ui/item_select.ogg")
	menu_ui_audio.pitch_scale = 1.0
	menu_ui_audio.play()

func open_load_carousel() -> void:
	back_button.visible = true
	current_carousel = load_carousel
	populate_menu_array(current_carousel)
	select_item(item_idx)

	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)

	load_carousel.visible = true
	tween.tween_property(load_carousel, "scale", Vector3.ONE, TWEEN_DURATION)
	tween.parallel().tween_property(carousel, "scale", Vector3(0.05, 0.05, 0.05), TWEEN_DURATION)
	tween.connect("finished", _on_carousel_hidden)

func change_ui() -> void:
	pass

func _on_carousel_hidden() -> void:
	carousel.visible = false

func _on_load_carousel_hidden() -> void:
	load_carousel.visible = false

func _on_left_button_pressed() -> void:
	rotate_carousel("left")

func _on_right_button_pressed() -> void:
	rotate_carousel("right")

func _on_menu_item_button_pressed() -> void:
	perform_menu_action(menu_items[item_idx].name)

func _on_back_button_pressed() -> void:
	back_button.visible = false
	current_carousel = carousel
	populate_menu_array(current_carousel)
	select_item(item_idx)
	
	menu_ui_audio.stream = preload("res://assets/audio/sound/ui/item_select.ogg")
	menu_ui_audio.pitch_scale = 1.0
	menu_ui_audio.play()

	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)

	carousel.visible = true
	tween.tween_property(carousel, "scale", Vector3.ONE, TWEEN_DURATION)
	tween.parallel().tween_property(load_carousel, "scale", Vector3(0.05, 0.05, 0.05), TWEEN_DURATION)
	tween.connect("finished", _on_load_carousel_hidden)
