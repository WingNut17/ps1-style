extends Node

# Dictionary of scenes keyed by level ID
var levels := {
	"main_menu": preload("res://scenes/ui/main_menu.tscn"),
	"floor_1": preload("res://scenes/levels/floors/floor_1.tscn"),
	"janitor": preload("res://scenes/levels/janitor_room.tscn"),
	"main_floor": preload("res://scenes/levels/floors/main_floor.tscn")
}

func get_scene(level_id: String) -> PackedScene:
	return levels.get(level_id)
