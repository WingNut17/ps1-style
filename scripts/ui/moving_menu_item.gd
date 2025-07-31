extends Node3D


var pos: Vector3
var mouse_position: Vector2
var default_rotation: Vector3
var item_selected: bool = false:
	set(value):
		item_selected = value
		if !value:
			var tween = get_tree().create_tween()
			tween.tween_property(self, "rotation_degrees", default_rotation, 0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)


func _ready() -> void:
	default_rotation = rotation_degrees
	pos = position

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_position = event.global_position
		mouse_position = Vector2(mouse_position.x - 160, mouse_position.y - 120)

func _process(delta: float) -> void:
	if item_selected:
		if pos.x > 0 or pos.z > 0:
			rotation_degrees = default_rotation + Vector3(mouse_position.y/7.5, mouse_position.x/7.5, 0)
		elif pos.x < 0 or pos.z < 0:
			rotation_degrees = default_rotation + Vector3(-mouse_position.y/7.5, mouse_position.x/7.5, 0)
