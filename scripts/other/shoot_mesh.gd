class_name ShootMesh
extends MeshInstance3D


const GLOCK_19 = preload("res://resources/shoot mesh/glock_19.tres")

var shoot_mesh_timer: Timer


func _ready() -> void:
	visible = false
	
	mesh = GLOCK_19
	
	shoot_mesh_timer = Timer.new()
	add_child(shoot_mesh_timer)
	shoot_mesh_timer.one_shot = true
	shoot_mesh_timer.wait_time = 0.05
	shoot_mesh_timer.connect("timeout", _on_shoot_mesh_timer_timeout)
	self.visibility_changed.connect(_on_visibility_changed)

func _on_visibility_changed() -> void:
	if visible:
		rotate_x(randi_range(-360, 360))
		shoot_mesh_timer.start()

func _on_shoot_mesh_timer_timeout() -> void:
	visible = false
