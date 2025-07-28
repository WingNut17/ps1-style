extends Node3D


@onready var room_num_label: Label3D = $RoomNumLabel

# when the room number value is set by the level loader it will update the label to match.
var room_number: int:
	set(value):
		room_number = value
		room_num_label.text = str(room_number)
