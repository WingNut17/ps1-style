extends Node3D

@onready var model: Node3D = $hotel_potted_plant

func _ready() -> void:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	model.rotation_degrees.y = rng.randi_range(0,8) * 45
