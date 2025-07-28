extends AudioStreamPlayer


## This one off script just plays the audio blip whenever a character is displayed in the text box.
func _on_dialogue_label_spoke(letter: String, letter_index: int, speed: float) -> void:
	pitch_scale = randf_range(0.8, 1.2)
	play()
