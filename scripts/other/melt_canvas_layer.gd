extends CanvasLayer


@export var main: Node3D
@export var buffer_time: float = 0.5
@export var melt_duration: float = 2.0
@export var level_text_time: float = 3.0
@export var column_count: int = 240

@onready var melt: ColorRect = $Melt
@onready var level_label: Label = $LevelLabel
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var melt_buffer: Timer = $MeltBufferTimer
@onready var level_text_timer: Timer = $LevelTextTimer

var melt_material: ShaderMaterial
var rng = RandomNumberGenerator.new()

var level_text: String

# for debugging. just to test how the transition works. 
# eventually this transition manager will be able to be called from something like DoorInteractable which extends Interactable objects
const LEVEL_1 = preload("res://level_1.tscn")
const LEVEL_2 = preload("res://level_2.tscn")


func _ready() -> void:
	melt.visible = false
	level_label.visible = false
	
	melt_buffer.wait_time = buffer_time
	level_text_timer.wait_time = level_text_time
	melt_buffer.one_shot = true
	level_text_timer.one_shot = true
	melt_buffer.connect("timeout", _on_wait_timer_timeout)
	level_text_timer.connect("timeout", _on_level_text_timer_timeout)
	
	melt.material.set_shader_parameter("column_count", column_count)

func melt_transition(current_scene: Node3D, next_scene: PackedScene) -> void:
	rng.randomize()
	await get_tree().process_frame

	var image := get_viewport().get_texture().get_image()
	
	current_scene.queue_free()
	var next_scene_instance = next_scene.instantiate()
	level_text = next_scene_instance.editor_description
	main.add_child(next_scene_instance)
	main.level_instance = next_scene_instance
	
	if not image.is_empty():
		var freeze_frame := ImageTexture.create_from_image(image)

		var random_seed = rng.randf_range(0.0, 10000.0)
		melt.material.set_shader_parameter("random_seed", random_seed)
		melt.material.set_shader_parameter("screen_texture", freeze_frame)
		melt.material.set_shader_parameter("progress", 0.0)
		melt.visible = true
		
		melt_buffer.start()

func start_melt() -> void:
	var tween = create_tween()
	tween.tween_method(update_melt_progress, 0.0, 1.0, melt_duration)
	tween.connect("finished", _on_tween_finished)

func update_melt_progress(progress: float) -> void:
	melt.material.set_shader_parameter("progress", progress)

func _on_wait_timer_timeout() -> void:
	start_melt()

func _on_tween_finished() -> void:
	melt.visible = false
	level_label.visible = true
	level_label.modulate = Color(1,1,1,0)
	level_label.text = level_text
	
	var tween = create_tween()
	tween.tween_property(level_label, "modulate", Color(1,1,1,1), 1)
	
	level_text_timer.start()

func _on_level_text_timer_timeout() -> void:
	var tween = create_tween()
	tween.tween_property(level_label, "modulate", Color(1,1,1,0), 1)
