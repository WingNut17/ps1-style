extends Node3D


@onready var light: OmniLight3D = $OmniLight3D
@onready var fluorescent_hum: AudioStreamPlayer3D = $FluorescentHum
@onready var flicker: AudioStreamPlayer3D = $Flicker

@export var toggled: bool = true:
	set = toggle_light
@export var flickering: bool = false:
	set = toggle_flickering
@export var flicker_speed: float = 0.1
var flicker_timer: float = 0.0


func _ready() -> void:
	toggle_light(toggled)
	toggle_flickering(flickering)

func toggle_light(value: bool) -> void:
	toggled = value
	if light:
		if value:
			light.light_energy = 1.0
			fluorescent_hum.play()
		else:
			light.light_energy = 0.0
			fluorescent_hum.stop()

func toggle_flickering(value: bool) -> void:
	flickering = value
	if flicker:
		if flickering:
			toggled = value
			flicker.play()
		else:
			flicker.stop()

func _process(delta: float) -> void:
	if flickering:
		flicker_timer += delta
		if flicker_timer >= flicker_speed:
			if light:
				light.light_energy = randf_range(0.5, 1.5)
			flicker_timer = 0.0
