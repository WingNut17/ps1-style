class_name OneShotParticle
extends GPUParticles3D

func set_and_play(direction: Vector3, texture: Texture2D) -> void:
	set("one_shot", true)
	
	if process_material:
		#set("process_material/direction", direction)
		process_material.direction = direction
	if draw_pass_1 and draw_pass_1.material:
		#set("draw_pass_1/material/albedo_texture", texture)
		draw_pass_1.material.albedo_texture = texture
	
	self.connect("finished", _on_finished)
	
	emitting = true

func _on_finished() -> void:
	print("deleted")
	self.queue_free()
