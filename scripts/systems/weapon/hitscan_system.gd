class_name HitscanSystem
extends Node


var gun_stats: WeaponStats

const BULLET_IMPACT = preload("res://scenes/other/bullet_impact.tscn")
const BLOOD_SPLATTER = preload("res://assets/textures/particles/blood_splatter.png")
const CONCRETE = preload("res://assets/textures/general/concrete.png")


func initialize(stats: WeaponStats) -> void:
	self.name = "HitscanSystem"
	gun_stats = stats

func perform_hitscan(camera: Camera3D) -> void:
	var middle_of_screen = Vector2(160, 120)
	var from = camera.project_ray_origin(middle_of_screen)
	var base_dir = camera.project_ray_normal(middle_of_screen)
	var to = from + base_dir * gun_stats.shoot_distance
	
	var space_state = camera.get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collide_with_areas = true
	query.collide_with_bodies = true
	
	var result = space_state.intersect_ray(query)
	if result:
		handle_hit(result)

func handle_hit(result: Dictionary) -> void:
	if result.collider is HurtBox:
		var hurtbox = result.collider as HurtBox
		hurtbox.take_damage_from_hitscan(gun_stats.shoot_damage)
		create_impact_effect(result, hurtbox.type)
	else:
		create_impact_effect(result, "")

func create_impact_effect(result: Dictionary, target_type: String) -> void:
	var bullet_impact = BULLET_IMPACT.instantiate()
	bullet_impact.position = result.position
	
	if target_type == "NPC":
		bullet_impact.set_and_play(result.normal, BLOOD_SPLATTER)
	else:
		bullet_impact.set_and_play(result.normal, CONCRETE)
	
	get_tree().root.add_child(bullet_impact)
