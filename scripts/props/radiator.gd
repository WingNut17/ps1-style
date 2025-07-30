extends Node3D


@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var timer: Timer = $Timer


func _ready() -> void:
	timer.wait_time = randf_range(60, 120)
	timer.start

func _on_timer_timeout() -> void:
	audio_stream_player_3d.play()
	
	timer.wait_time = randf_range(60, 120)
	timer.start
