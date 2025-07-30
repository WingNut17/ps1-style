extends Node

# Dictionary of scenes keyed by level ID
var levels := {
	"level_1": preload("res://scenes/levels/level_1.tscn"),
	"level_2": preload("res://scenes/levels/level_2.tscn"),
	"floor_1": preload("res://scenes/levels/floors/floor_1.tscn"),
	"janitor": preload("res://scenes/levels/janitor_room.tscn"),
	"main_floor": preload("res://scenes/levels/floors/main_floor.tscn")
}

func get_scene(level_id: String) -> PackedScene:
	return levels.get(level_id)
