class_name RangedWeapon
extends Node3D


@export var shoot_smoke: PackedScene = preload(Constants.SCENE_PATHS.shoot_smoke)
@export var barrel_smoke: PackedScene = preload(Constants.SCENE_PATHS.barrel_smoke)
@export var shoot_mesh: MeshInstance3D
@export var barrel_pos: Marker3D

var shoot_smoke_instance: OneShotParticle
var barrel_smoke_instance: OneShotParticle


func _ready() -> void:
	shoot_smoke_instance = shoot_smoke.instantiate()
	barrel_smoke_instance = barrel_smoke.instantiate()

func shoot() -> void:
	shoot_mesh.visible = true
	
	shoot_smoke_instance = shoot_smoke.instantiate()
	barrel_smoke_instance = barrel_smoke.instantiate()
	
	barrel_pos.add_child(shoot_smoke_instance)
	barrel_pos.add_child(barrel_smoke_instance)
