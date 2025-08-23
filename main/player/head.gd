class_name Head
extends Node3D

@export var hand: Node3D
@export var sensitivity: float = 0.25
@export var hand_follow_speed: float = 16.0
@export var hand_lag_amount: float = 0.5
@export var max_lag_degrees: float = 20.0

@onready var camera_3d: Camera3D = $Camera3D

var target_hand_rotation: Vector3


func _process(delta: float) -> void:
	if hand:
		var target_rotation = rotation_degrees
		target_hand_rotation = target_hand_rotation.lerp(target_rotation, hand_follow_speed * delta)

		# Clamp difference so it can't fall too far behind
		var diff = target_rotation - target_hand_rotation
		diff.x = clamp(diff.x, -max_lag_degrees, max_lag_degrees)
		diff.y = clamp(diff.y, -max_lag_degrees, max_lag_degrees)
		diff.z = clamp(diff.z, -max_lag_degrees, max_lag_degrees)

		# Apply clamped rotation
		hand.rotation_degrees = target_rotation - diff

func look_at_object(object_position: Vector3, duration: float) -> void:
	var head_transform = global_transform
	head_transform = head_transform.looking_at(object_position, Vector3.UP)
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_transform", head_transform, duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
