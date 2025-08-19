extends CanvasLayer


@export var buffer_time: float = 0.5
@export var melt_duration: float = 2.0
@export var level_text_time: float = 3.0
@export var column_count: int = 240

@onready var melt: ColorRect = $ColorRect
@onready var level_label: Label = $LevelLabel
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var melt_buffer: Timer = $MeltBufferTimer
@onready var level_text_timer: Timer = $LevelTextTimer

var melt_material: ShaderMaterial
var rng = RandomNumberGenerator.new()

var tween: Tween


func _ready() -> void:
	tween = get_tree().create_tween()
	tween.stop()
	
	melt.visible = false
	level_label.visible = false
	
	melt_buffer.wait_time = buffer_time
	level_text_timer.wait_time = level_text_time

	melt_buffer.connect("timeout", _on_wait_timer_timeout)
	level_text_timer.connect("timeout", _on_level_text_timer_timeout)
	
	melt.material.set_shader_parameter("column_count", column_count)

func melt_transition(level_name: String) -> void:
	_reset_transitions()

	rng.randomize()
	await get_tree().process_frame

	level_label.text = level_name

	var image := get_viewport().get_texture().get_image()
	var freeze_frame := ImageTexture.create_from_image(image)
	var random_seed = rng.randf_range(0.0, 10000.0)

	melt.material.set_shader_parameter("random_seed", random_seed)
	melt.material.set_shader_parameter("screen_texture", freeze_frame)
	melt.material.set_shader_parameter("progress", 0.0)
	melt.visible = true

	melt_buffer.start()
	
	audio_stream_player.pitch_scale = rng.randf_range(0.9, 1.1)
	audio_stream_player.play()

func start_melt() -> void:
	if tween:
		tween.kill()
	
	tween = create_tween()
	
	tween.tween_method(update_melt_progress, 0.0, 1.0, melt_duration)
	tween.connect("finished", _on_tween_finished)
	
	GameState.start_loading()

func update_melt_progress(progress: float) -> void:
	melt.material.set_shader_parameter("progress", progress)

func _reset_transitions() -> void:
	# Kill any running tween
	if tween:
		tween.kill()
		tween = null

	# Stop timers
	if melt_buffer.time_left > 0:
		melt_buffer.stop()
	if level_text_timer.time_left > 0:
		level_text_timer.stop()

	# Hide and reset label
	level_label.visible = false
	level_label.modulate = Color(1,1,1,0)

	# Reset shader progress
	melt.material.set_shader_parameter("progress", 0.0)
	audio_stream_player.stop()

func _on_wait_timer_timeout() -> void:
	start_melt()

func _on_tween_finished() -> void:
	if tween and tween.is_running():
		return

	melt.visible = false
	level_label.visible = true
	level_label.modulate = Color(1,1,1,0)
	
	tween = create_tween()
	tween.tween_property(level_label, "modulate", Color(1,1,1,1), 1)
	
	level_text_timer.start()
	
	GameState.end_loading()

func _on_level_text_timer_timeout() -> void:
	tween = create_tween()
	tween.tween_property(level_label, "modulate", Color(1,1,1,0), 1)
