extends Node


# Signals for state changes
signal game_paused
signal game_unpaused
signal cutscene_started
signal cutscene_ended
signal dialogue_started
signal dialogue_ended
signal menu_opened
signal menu_closed

# Game state flags
var is_paused: bool = false
var is_cutscene_playing: bool = false
var is_in_dialogue: bool = false
var is_in_menu: bool = false
var is_loading: bool = false
var player_can_move: bool = true


func _ready() -> void:
	# Set process mode so this script continues running when paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	connect_dialogue_manager()

func pause_game() -> void:
	if not is_paused:
		is_paused = true
		get_tree().paused = true
		_update_player_movement()
		game_paused.emit()

func unpause_game() -> void:
	if is_paused:
		is_paused = false
		get_tree().paused = false
		_update_player_movement()
		game_unpaused.emit()

func toggle_pause() -> void:
	if is_paused:
		unpause_game()
	else:
		pause_game()

func start_cutscene() -> void:
	if not is_cutscene_playing:
		is_cutscene_playing = true
		_update_player_movement()
		cutscene_started.emit()

func end_cutscene() -> void:
	if is_cutscene_playing:
		is_cutscene_playing = false
		_update_player_movement()
		cutscene_ended.emit()

func start_dialogue(_val) -> void:
	if not is_in_dialogue:
		is_in_dialogue = true
		_update_player_movement()
		dialogue_started.emit()

func end_dialogue(_val) -> void:
	if is_in_dialogue:
		is_in_dialogue = false
		_update_player_movement()
		dialogue_ended.emit()

func connect_dialogue_manager() -> void:
	if DialogueManager:
		DialogueManager.dialogue_started.connect(start_dialogue)
		DialogueManager.dialogue_ended.connect(end_dialogue)

func open_menu() -> void:
	if not is_in_menu:
		is_in_menu = true
		_update_player_movement()
		menu_opened.emit()

func close_menu() -> void:
	if is_in_menu:
		is_in_menu = false
		_update_player_movement()
		menu_closed.emit()

func start_loading() -> void:
	is_loading = true
	_update_player_movement()

func end_loading() -> void:
	is_loading = false
	_update_player_movement()

func _update_player_movement() -> void:
	player_can_move = not (is_cutscene_playing or is_in_dialogue or is_in_menu or is_loading)
	print_state()

func should_block_player_input() -> bool:
	return not player_can_move

func is_any_blocking_state_active() -> bool:
	return is_cutscene_playing or is_in_dialogue or is_in_menu or is_loading

# Debug function to print current state
func print_state() -> void:
	var states: Dictionary[String, bool] = {
		"Paused": is_paused,
		"Cutscene": is_cutscene_playing,
		"Dialogue": is_in_dialogue,
		"Menu": is_in_menu,
		"Loading": is_loading,
		"Player can move": player_can_move
	} 
	
	for key in states:
		if states[key]:
			print("GAME STATE: ", key, " = true")
