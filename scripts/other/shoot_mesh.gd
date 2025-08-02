class_name ShootMesh
extends MeshInstance3D

var shoot_mesh_timer: Timer

func _ready() -> void:
	visible = false
	self.connect("visibility_changed", _on_shoot_mesh_visibility_changed)
	
	shoot_mesh_timer = Timer.new()
	add_child(shoot_mesh_timer)
	shoot_mesh_timer.one_shot = true
	shoot_mesh_timer.wait_time = 0.1
	shoot_mesh_timer.connect("timeout", _on_shoot_mesh_timer_timeout)

func _on_shoot_mesh_visibility_changed() -> void:
	if visible == true:
		shoot_mesh_timer.start()

func _on_shoot_mesh_timer_timeout() -> void:
	visible = false
