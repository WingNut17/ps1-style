extends CanvasLayer

@onready var noise_texture: TextureRect = $TextureRect

func _process(delta: float) -> void:
	noise_texture.texture.noise.seed = randi_range(0, 1024)
