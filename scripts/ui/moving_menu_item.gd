extends Node3D


var default_rotation: Vector3
var mouse_position: Vector2
var item_selected: bool = false:
	set(value):
		item_selected = value
		if not value:
			var tween = get_tree().create_tween()
			tween.tween_property(self, "rotation", default_rotation, 0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)


func _ready() -> void:
	default_rotation = rotation

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_position = event.global_position

func _process(delta: float) -> void:
	if not item_selected:
		return
	
	var screen_center = Vector2(160, 120)
	var offset = mouse_position - screen_center

	var x_tilt = clamp(offset.y / 300.0, -0.3, 0.3)
	var y_tilt = clamp(offset.x / 300.0, -0.3, 0.3)
	
	# Play
	if position.x > 0 and position.z == 0:
		var tilt = Vector3(0, y_tilt, -x_tilt)
		rotation = default_rotation + tilt
	
	# Settings
	if position.x > 0 and position.z > 0:
		var tilt = Vector3(0, y_tilt, -x_tilt)
		rotation = default_rotation + tilt
	
	# Credits
	elif position.x < 0 and position.z > 0:
		var tilt = Vector3(x_tilt, y_tilt, 0)
		rotation = default_rotation + tilt
	
	# Load
	elif position.x < 0 and position.z < 0:
		var tilt = Vector3(0, y_tilt, x_tilt)
		rotation = default_rotation + tilt
	
	# Exit button
	elif position.x > 0 and position.z < 0:
		var tilt = Vector3(0, y_tilt, x_tilt)
		rotation = default_rotation + tilt
