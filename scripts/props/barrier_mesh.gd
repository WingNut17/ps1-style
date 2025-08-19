extends MeshInstance3D

var player: CharacterBody3D

func _ready() -> void:
	player = get_tree().root.get_node("/root/Main/Player")

func _process(delta: float) -> void:
	if player:
		self.mesh.material.set_shader_parameter("player_position", player.position)
