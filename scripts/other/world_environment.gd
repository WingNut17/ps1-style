@tool
extends WorldEnvironment
## This script just used to turn on and the environment within the editor

@export var enabled_in_editor: bool = false:
	set(value):
		enabled_in_editor = value
		_update_environment()
@export var environment_resource: Environment = preload(Constants.RESOURCE_PATHS.environment)


func _ready():
	_update_environment()

func _update_environment():
	if Engine.is_editor_hint():
		if enabled_in_editor:
			environment = environment_resource
		else:
			environment = null
	else:
		environment = environment_resource
