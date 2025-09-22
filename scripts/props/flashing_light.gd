extends OmniLight3D

@export var toggled: bool = true:
	set = toggle_light
@export var flickering: bool = false:
	set = toggle_flickering
@export var flicker_speed: float = 0.1
@export var range: Array = [0.25, 0.5]
var flicker_timer: float = 0.0


func _ready() -> void:
	toggle_light(toggled)
	toggle_flickering(flickering)

func toggle_light(value: bool) -> void:
	toggled = value

	if value:
		light_energy = 1.0
	else:
		light_energy = 0.0

func toggle_flickering(value: bool) -> void:
	flickering = value
	if flickering:
		toggled = value

func _process(delta: float) -> void:
	if flickering:
		flicker_timer += delta
		if flicker_timer >= flicker_speed:
			light_energy = randf_range(range.min(), range.max())
			flicker_timer = 0.0
