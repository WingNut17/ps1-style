extends Node3D


@export var crosshair: TextureRect
@export var sensitivity: float = 0.25


var can_move: bool = true:
	set(value):
		can_move = value
		if !can_move:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			crosshair.visible = false
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			crosshair.visible = true


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	if !can_move:
		return
	
	if event is InputEventMouseMotion:
		var movement: Vector2 = event.relative  
		rotation_degrees.y -= movement.x * sensitivity
		rotation_degrees.x -= movement.y * sensitivity
		rotation_degrees.x = clampf(rotation_degrees.x, -90, 90)

func look_at_object(object_position: Vector3, duration: float):
	var head_transform = global_transform
	head_transform = head_transform.looking_at(object_position, Vector3.UP)
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_transform", head_transform, duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
