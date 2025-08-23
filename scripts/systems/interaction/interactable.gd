class_name Interactable
extends Area3D

var main: Node3D
var can_interact: bool = true
var debug_error: String = ""

func _ready() -> void:
	collision_layer = 0
	collision_mask = 0
	
	set_collision_layer_value(3, true)
	
	monitoring = false
