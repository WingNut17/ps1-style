extends Level

@export var sky_rotate_speed: float = 1.0

@onready var world_environment: WorldEnvironment = $WorldEnvironment


func _ready() -> void:
	MusicManager.fade_music(Constants.MUSIC_PATHS.tile_music, -15)
	
	var bus_index := AudioServer.get_bus_index("Sfx")
	AudioServer.set_bus_effect_enabled(bus_index, 0, true)

func _process(delta: float) -> void:
	world_environment.environment.sky_rotation.z += delta * sky_rotate_speed
