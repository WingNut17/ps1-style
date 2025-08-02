class_name WeaponAudioManager
extends Node


var gun_stats: WeaponStats
var audio_player: AudioStreamPlayer


func initialize(stats: WeaponStats) -> void:
	self.name = "WeaponAudioManager"
	gun_stats = stats
	
	audio_player = AudioStreamPlayer.new()
	audio_player.bus = "Sfx"
	add_child(audio_player)

func play_shoot_sound() -> void:
	_play_sound(gun_stats.shoot_sound, 0.8, 1.2)

func play_reload_sound() -> void:
	_play_sound(gun_stats.reload_sound, 0.9, 1.1)

func play_no_ammo_sound() -> void:
	_play_sound(gun_stats.no_ammo_sound, 0.8, 1.2)

func _play_sound(sound: AudioStream, pitch_min: float = 0.8, pitch_max: float = 1.2) -> void:
	if audio_player and sound:
		audio_player.stream = sound
		audio_player.pitch_scale = randf_range(pitch_min, pitch_max)
		audio_player.play()
