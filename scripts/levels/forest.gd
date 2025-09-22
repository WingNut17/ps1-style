extends Node3D

@export_enum("STRING") var curves: String

@onready var grid_map: GridMap = %GridMap
@onready var grid_map_2: GridMap = %GridMap2
@onready var camera_3d: Camera3D = $Camera3D
@onready var timer: Timer = $Timer

var default_pos: Vector3
var default_rotation: Vector3
var lerp_pos: Vector3
var lerp_rotation: Vector3

func _ready():
	default_pos = camera_3d.position
	default_rotation = camera_3d.rotation_degrees
	
	timer.timeout.connect(_on_timer_timeout)
	
	randomize_tree_rotations(grid_map)
	randomize_tree_rotations(grid_map_2)

func _process(delta: float) -> void:
	camera_3d.position = lerp(camera_3d.position, lerp_pos, delta)
	camera_3d.rotation_degrees = lerp(camera_3d.rotation_degrees, lerp_rotation, delta)

#func tween_curve(v, curve): return curves[curve].sample_baked(v)

func _on_timer_timeout() -> void:
	timer.wait_time = randf_range(0.25, 0.5)
	
	lerp_pos = default_pos + Vector3(randf_range(-0.05, 0.05), randf_range(-0.05, 0.05), randf_range(-0.05, 0.05))
	lerp_rotation = default_rotation + Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1))

func randomize_tree_rotations(grid_map_check):
	# Get all used cells in the gridmap
	var used_cells = grid_map_check.get_used_cells()
	
	# Iterate through each cell
	for cell_pos in used_cells:
		# Get the current item index at this position
		var item_index = grid_map_check.get_cell_item(cell_pos)
		
		# Skip if no item is placed
		if item_index == -1:
			continue
			
		# Generate a random Y rotation (0 to 360 degrees)
		var random_y_rotation = randf() * 360.0
		
		# Convert to radians
		var rotation_radians = deg_to_rad(random_y_rotation)
		
		# Create a rotation transform around Y axis
		var rotation_transform = Transform3D()
		rotation_transform = rotation_transform.rotated(Vector3.UP, rotation_radians)
		
		# Apply the rotation to the cell
		grid_map_check.set_cell_item(cell_pos, item_index, grid_map_check.get_cell_item_orientation(cell_pos))
		
		# Get the current basis and apply our rotation
		var current_basis = grid_map_check.get_cell_item_basis(cell_pos)
		var new_basis = current_basis * Basis(Vector3.UP, rotation_radians)
		
		# Set the new orientation
		grid_map_check.set_cell_item(cell_pos, item_index, grid_map_check.get_orthogonal_index_from_basis(new_basis))
