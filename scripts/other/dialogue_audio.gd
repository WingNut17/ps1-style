extends AudioStreamPlayer


func _on_dialogue_label_spoke(letter: String, letter_index: int, speed: float) -> void:
	pitch_scale = randf_range(0.8, 1.2)
	play()
