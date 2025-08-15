extends Node


signal pick_up_item

var item: String


func pick_up() -> void:
	pick_up_item.emit()
