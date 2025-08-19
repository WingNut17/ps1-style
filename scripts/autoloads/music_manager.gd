extends Node

@export var player_a: AudioStreamPlayer
@export var player_b: AudioStreamPlayer

var active_player: AudioStreamPlayer
var inactive_player: AudioStreamPlayer
var tween: Tween

func _ready() -> void:
	active_player = player_a
	inactive_player = player_b


func adjust_volume(amount: float, instantly: bool = false, fade_time: float = 2.0) -> void:
	"""Sets the volume of the primary audio player 
	either instantly or over time."""
	
	if instantly:
		active_player.volume_db += amount
		return
	
	var current_volume = active_player.volume_db
	
	# Stop tween if still running
	if tween and tween.is_running():
		tween.kill()
	
	tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(active_player, "volume_db", current_volume + amount, fade_time)

func fade_music(audio_path: String, volume: float = 0.0, fade_time: float = 5.0) -> void:
	"""Fades slowly between two songs"""
	
	var current_volume = active_player.volume_db
	
	var new_stream = load(audio_path)
	if active_player.stream == new_stream:
		return # Already playing this track
	
	# Stop tween if still running
	if tween and tween.is_running():
		tween.kill()
			
	inactive_player.stream = new_stream
	inactive_player.volume_db = -80.0 # silent
	inactive_player.play()

	# Crossfade volumes
	tween = create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween.tween_property(inactive_player, "volume_db", volume, fade_time)
	
	tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
	tween.set_parallel().tween_property(active_player, "volume_db", -80.0, fade_time)
	
	# Swap active players when done
	tween.finished.connect(rearrange_players)

func rearrange_players() -> void:
	active_player.stop()
	var temp = active_player
	active_player = inactive_player
	inactive_player = temp
