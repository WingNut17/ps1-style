class_name WeaponAnimationManager
extends Node


var weapon_stats: WeaponStats
var shoot_timer: Timer
var reload_timer: Timer
var full_auto_timer: Timer
var can_shoot: bool = true
var is_full_auto_active: bool = false
var weapon_node: Node3D
var shoot_mesh: MeshInstance3D
var camera_node: Camera3D
var head_node: Node3D
var tween: Tween


func initialize(stats: WeaponStats, weapon: Node3D, camera: Camera3D, head: Node3D) -> void:
	self.name = "WeaponAnimationManager"
	weapon_stats = stats
	weapon_node = weapon
	camera_node = camera
	head_node = head
	
	shoot_mesh = weapon_node.get_node_or_null("ShootMesh")
	if shoot_mesh:
		shoot_mesh.visible = false
		
	# Set up shoot cooldown timer
	shoot_timer = Timer.new()
	add_child(shoot_timer)
	shoot_timer.one_shot = true
	shoot_timer.wait_time = stats.shoot_speed
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)
	
	# Set up reload timer
	reload_timer = Timer.new()
	add_child(reload_timer)
	reload_timer.one_shot = true
	reload_timer.wait_time = stats.reload_time
	reload_timer.timeout.connect(_on_reload_timer_timeout)
	
	# Set up full auto timer
	full_auto_timer = Timer.new()
	add_child(full_auto_timer)
	full_auto_timer.wait_time = stats.shoot_speed
	full_auto_timer.timeout.connect(_on_full_auto_timer_timeout)

func play_shoot_animation() -> void:
	can_shoot = false
	shoot_timer.start()
	
	if tween:
		tween.kill()
	
	tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	
	if weapon_stats.type == "Gun":
		if shoot_mesh:
			shoot_mesh.visible = true
			shoot_mesh.rotation_degrees.x = randi_range(-360, 360)
		
		head_node.rotation_degrees = Vector3(
			clamp(head_node.rotation_degrees.x + randf_range(1, 5) * weapon_stats.recoil_amount, -90, 90),
			head_node.rotation_degrees.y + randf_range(-2.5, 2.5) * weapon_stats.recoil_amount,
			0
			)
		
		camera_node.rotation_degrees = Vector3(randf_range(10,15), randf_range(-5, 5), randf_range(-5, 5)) * weapon_stats.recoil_amount
		weapon_node.rotation_degrees.z = randf_range(-15, -10) * weapon_stats.recoil_amount
		weapon_node.position = Vector3(randf_range(0.1, 0.2), randf_range(0.1, 0.2), randf_range(-0.1, 0.1)) * weapon_stats.recoil_amount
		
		tween.tween_property(camera_node, "rotation_degrees", Vector3.ZERO, weapon_stats.shoot_speed * 2)
		tween.set_parallel().tween_property(weapon_node, "rotation_degrees", Vector3.ZERO, weapon_stats.shoot_speed * 2)
		tween.set_parallel().tween_property(weapon_node, "position", Vector3.ZERO, weapon_stats.shoot_speed * 2)
	
	elif weapon_stats.type == "Melee":
		pass

func play_reload_animation() -> void:
	if weapon_stats.type != "Gun":
		return
		
	can_shoot = false
	reload_timer.start()
	
	if tween:
		tween.kill()
	
	tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	
	tween.tween_property(weapon_node, "rotation_degrees", Vector3(0, 0, 30), weapon_stats.reload_time/2)
	tween.set_parallel().tween_property(weapon_node, "position", Vector3(0, -0.3, 0), weapon_stats.reload_time/2)
	
	tween.connect("finished", _on_reload_down_finished)

func start_full_auto() -> void:
	if weapon_stats.full_auto:
		is_full_auto_active = true
		full_auto_timer.start()

func stop_full_auto() -> void:
	is_full_auto_active = false
	full_auto_timer.stop()

func can_shoot_currently() -> bool:
	return can_shoot

func _on_shoot_timer_timeout() -> void:
	can_shoot = true

func _on_reload_timer_timeout() -> void:
	can_shoot = true

func _on_full_auto_timer_timeout() -> void:
	if is_full_auto_active:
		get_parent().attempt_full_auto_shot()
		full_auto_timer.start()

func _on_reload_down_finished() -> void:
	if tween:
		tween.kill()
	
	tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	
	tween.tween_property(weapon_node, "rotation_degrees", Vector3.ZERO, weapon_stats.reload_time/2)
	tween.set_parallel().tween_property(weapon_node, "position", Vector3.ZERO, weapon_stats.reload_time/2)
