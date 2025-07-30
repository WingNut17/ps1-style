extends Level


@onready var police_siren: AudioStreamPlayer3D = $PoliceSiren
@onready var police_siren_timer: Timer = $PoliceSiren/Timer


func _ready() -> void:
	police_siren_timer.wait_time = randf_range(60, 240)
	police_siren.pitch_scale = randf_range(0.8, 1.2)

func _on_timer_timeout() -> void:
	police_siren_timer.wait_time = randf_range(60, 240)
	police_siren.pitch_scale = randf_range(0.8, 1.2)
	police_siren.play
