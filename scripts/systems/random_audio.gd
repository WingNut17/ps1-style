class_name RandomAudio
extends AudioStreamPlayer3D


@export_range (0.0, 600.0) var random_time: Array[float] = [30.0, 60.0] ## The minimum time, and a maximum time for how often the audio will play.
@export_range (0.0, 2.0) var random_pitch: Array[float] = [0.8, 1.2]  ## The minimum pitch, and a maximum pitch for the audio.
@export var random_sounds: Array[AudioStreamOggVorbis] ## Bank of sounds it will randomly pick between.

var timer: Timer


func _ready() -> void:
	timer = Timer.new()
	timer.one_shot = true
	add_child(timer)  
	
	timer.timeout.connect(play_sound)
	
	timer.wait_time = randf_range(random_time.min(), random_time.max())
	pitch_scale = randf_range(random_pitch.min(), random_pitch.max())
	
	timer.start()

func play_sound() -> void:
	if random_sounds.size() > 0:
		var selected_sound = random_sounds[randi_range(0, random_sounds.size() - 1)]
		stream = selected_sound
		
		timer.wait_time = randf_range(random_time.min(), random_time.max())
		pitch_scale = randf_range(random_pitch.min(), random_pitch.max())
		
		play()
		timer.start()

	else:
		if stream == null:
			return
		else:
			play()
		timer.start()  
