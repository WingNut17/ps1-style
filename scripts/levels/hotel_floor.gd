class_name HotelFloor
extends Level
## Used to initate props based on level floor level, as well as pass unique events.


@export var floor_number: int


# Creates an array of all the doors in the level
func _ready() -> void:
	AudioServer.set_bus_effect_enabled(2, 0, false)
	
	if has_node("Props"):
		var props : Node3D = get_node("Props")
		
		if props.has_node("Doors"):
			var doors : Node3D = props.get_node("Doors")
			
			var door_nodes : Array = []
			
			# Get all the doors in the door node
			for door in doors.get_children():
				var node_name = door.name.rstrip("0123456789")
				
				if node_name == "HotelDoorRoom":
					door_nodes.append(door)

					if floor_number:
						door.room_number = (floor_number * 100) + int(door_nodes.size())
					
			if door_nodes == null:
				print("Level initiation: No hotel door props found!")
		else:
			print("Level initiation: No door node found!")
	else:
		print("Level initiation: No prop node found!")
