extends Node


signal pick_up_item
signal unlock_door

var item: String


func pick_up() -> void:
	pick_up_item.emit()

func unlock_locked_object() -> void:
	unlock_door.emit()
