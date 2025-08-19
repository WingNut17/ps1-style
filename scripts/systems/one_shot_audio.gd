class_name OneShotAudio
extends AudioStreamPlayer


@export_range (0.0, 2.0) var random_pitch: Array[float] = [0.9, 1.1]  ## The minimum pitch, and a maximum pitch for the audio.


func play_audio() -> void:
	pitch_scale = randf_range(random_pitch.min(), random_pitch.max())
	play()
