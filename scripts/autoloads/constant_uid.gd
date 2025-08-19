extends Node


const LEVEL_PATHS : Dictionary[String, String] = {
	"main_menu": "uid://c35bmvjx4x8iu",
	"floor_1": "uid://chimn3gxcbey7",
	"janitors_room": "uid://b02i8t36xvyu6",
	"main_floor": "uid://vu68h5sot7hb",
	"tile_level": "uid://oukrlyvriv3s"
}

const SCENE_PATHS : Dictionary[String, String] = {
	"player": "uid://b5k7b61oxm2pt",
	"main_menu": "uid://c35bmvjx4x8iu",
	"shoot_smoke": "uid://dqli2a3bq4n45",
	"barrel_smoke": "uid://ckacb1wxobqqf",
	"bullet_impact": "uid://dmicaoqtjq1bf"
}

const RESOURCE_PATHS : Dictionary[String, String] = {
	"environment": "uid://cdn107mv7e8ox",
	"shoot_mesh": "uid://6ua2sdg2exgj"
}

const AUDIO_PATHS : Dictionary[String, String] = {
	"menu_move": "uid://crh6tg4yexskn",
	"item_select": "uid://dnuynm0yojx4v"
}

const MUSIC_PATHS : Dictionary[String, String] = {
	"tile_music": "uid://fat0r0wemb5m",
	"tile_music2": "uid://di7ax3jmdpuv2"
}

static func get_scene(scene_id: String) -> PackedScene:
	"""
	Returns the packed scene given the name or uid.
	"""
	
	var uid_to_load: String
	
	if scene_id.begins_with("uid://"):
		uid_to_load = scene_id
	
	elif scene_id in Constants.LEVEL_PATHS:
		uid_to_load = Constants.LEVEL_PATHS[scene_id]
	else:
		push_error("Unknown scene identifier: %s" % scene_id)
		return null
	
	return load(uid_to_load)
