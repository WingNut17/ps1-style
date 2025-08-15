extends CanvasLayer


func _ready() -> void:
	# Connect to game state signals
	GameState.cutscene_started.connect(_hide_player_ui)
	GameState.cutscene_ended.connect(_show_player_ui)
	GameState.dialogue_started.connect(_hide_player_ui)
	GameState.dialogue_ended.connect(_show_player_ui)
	GameState.menu_opened.connect(_hide_player_ui)
	GameState.menu_closed.connect(_show_player_ui)

func _hide_player_ui() -> void:
	self.visible = false

func _show_player_ui() -> void:
	self.visible = true
