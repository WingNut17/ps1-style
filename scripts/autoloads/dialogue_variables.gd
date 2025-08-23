extends Node


signal pick_up_item
signal unlock_door

@export var item_color: Color = Color.RED.to_html()
@export var item: String:
	set(value):
		item = str("[color=", item_color, "]", value, "[/color]")

const NPC_NAMES : Dictionary[String, Color] = {
	"shawns": Color.LIGHT_CORAL
}

func get_npc(npc_name: String) -> String:
	npc_name = npc_name.to_lower()
	
	if npc_name in NPC_NAMES:
		var name_formatted = str(
			"[color=%s]" % NPC_NAMES.get(npc_name).to_html(),
			npc_name,
			"[/color]"
		)
		return name_formatted
	else:
		return "null"

func pick_up() -> void:
	pick_up_item.emit()

func unlock_locked_object() -> void:
	unlock_door.emit()
