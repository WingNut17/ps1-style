extends AudioStreamPlayer


## This one off script just plays the audio blip whenever a character is displayed in the text box.
func _on_dialogue_label_spoke(_letter: String, _letter_index: int, _speed: float) -> void:
	pitch_scale = randf_range(0.8, 1.2)
	play()
