class_name HitBox
extends Area3D


@export var damage: float = 1.0: 
	set = set_damage,
	get = get_damage


func set_damage(value: float):
	damage = value
	
func get_damage() -> float:
	return damage
