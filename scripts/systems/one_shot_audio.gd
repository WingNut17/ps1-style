class_name OneShotAudio
extends AudioStreamPlayer


@export_range (0.0, 2.0) var random_pitch: Array[float] = [0.9, 1.1]  ## The minimum pitch, and a maximum pitch for the audio.


func _ready() -> void:
	pass

func initialize(oneshot: bool = true) -> void:
	if oneshot:
		finished.connect(_on_finished, CONNECT_ONE_SHOT)
		play_audio()

func play_audio() -> void:
	pitch_scale = randf_range(random_pitch.min(), random_pitch.max())
	play()

func _on_finished() -> void:
	queue_free()
