extends RayCast3D
"""This script is used for getting the material of the ground the player is walking on
in order to play the correct walking noise."""


const CARPET_STEP = [
	preload("res://assets/audio/sound/characters/step/carpet_step1.ogg"),
	preload("res://assets/audio/sound/characters/step/carpet_step2.ogg"),
	preload("res://assets/audio/sound/characters/step/carpet_step3.ogg"),
	preload("res://assets/audio/sound/characters/step/carpet_step4.ogg"),
	preload("res://assets/audio/sound/characters/step/carpet_step5.ogg"),
	preload("res://assets/audio/sound/characters/step/carpet_step6.ogg")
]

const STONE_STEP = [
	preload("res://assets/audio/sound/characters/step/stone_step1.ogg"),
	preload("res://assets/audio/sound/characters/step/stone_step2.ogg"),
	preload("res://assets/audio/sound/characters/step/stone_step3.ogg"),
	preload("res://assets/audio/sound/characters/step/stone_step4.ogg"),
	preload("res://assets/audio/sound/characters/step/stone_step5.ogg"),
	preload("res://assets/audio/sound/characters/step/stone_step6.ogg")
]


@onready var walk_timer: Timer = $WalkTimer
@onready var walk_audio: AudioStreamPlayer = $WalkAudio

@export var walk_audio_speed: float ## How many seconds between walk sounds.


func _ready() -> void:
	walk_timer.wait_time = walk_audio_speed

func try_to_play_audio() -> void:
	if not walk_timer.is_stopped():
		return
	else:
		if is_colliding():
			var material = get_collider().editor_description
			
			if material:
				match material:
					"carpet":
						walk_audio.stream = CARPET_STEP[randi_range(0,CARPET_STEP.size()-1)]
					"stone":
						walk_audio.stream = STONE_STEP[randi_range(0,STONE_STEP.size()-1)]
					"dirt":
						pass
					"wood":
						pass
					_:
						pass
			
				walk_audio.pitch_scale = randf_range(0.9, 1.1)
				walk_audio.play()
				
				walk_timer.start()
