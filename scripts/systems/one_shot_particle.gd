class_name OneShotParticle
extends GPUParticles3D


func _ready() -> void:
	set("one_shot", true)
	self.connect("finished", _on_finished)
	emitting = true

func set_and_play(direction: Vector3, texture: Texture2D) -> void:
	if process_material:
		process_material.direction = direction
	if draw_pass_1 and draw_pass_1.material:
		draw_pass_1.material.albedo_texture = texture

func _on_finished() -> void:
	self.queue_free()
