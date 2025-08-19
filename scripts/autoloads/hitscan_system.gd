extends Node


const BULLET_IMPACT = preload(Constants.SCENE_PATHS.bullet_impact)
const BLOOD_SPLATTER = preload("res://assets/textures/particles/blood_splatter.png")
const CONCRETE = preload("res://assets/textures/general/concrete.png")


func perform_hitscan(camera: Camera3D, shoot_distance: float, damage: int, spread: float = 2.5) -> void:
	"""
	Performs a hitscan given the camera, distance, damage and spread.
	"""
	
	var middle_of_screen = get_tree().root.content_scale_size / 2
	var from = camera.project_ray_origin(middle_of_screen)
	var base_dir = camera.project_ray_normal(middle_of_screen)
	
	var to
	if spread:
		var spread_x = randf_range(-spread, spread)
		var spread_y = randf_range(-spread, spread)
		
		var spread_rad_x = deg_to_rad(spread_x)
		var spread_rad_y = deg_to_rad(spread_y)
		
		var right = camera.global_transform.basis.x
		var up = camera.global_transform.basis.y
		
		var spread_dir = base_dir
		spread_dir = spread_dir.rotated(right, spread_rad_y)  # Vertical spread
		spread_dir = spread_dir.rotated(up, spread_rad_x)     # Horizontal spread
		spread_dir = spread_dir.normalized()
		
		to = from + spread_dir * shoot_distance
	else:
		to = from + base_dir * shoot_distance
	
	var space_state = camera.get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	
	query.collide_with_areas = true
	query.collision_mask = 1
	query.collide_with_bodies = true
	
	var result = space_state.intersect_ray(query)
	
	if result:
		handle_hit(result, damage)

func handle_hit(result: Dictionary, damage: int) -> void:
	if result.collider is HurtBox:
		var hurtbox = result.collider as HurtBox
		hurtbox.take_damage_from_hitscan(damage)
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
