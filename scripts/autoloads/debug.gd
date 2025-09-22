extends Node

var full_msg: String
var return_msg: String
var parse: Array

func parse_code(code: String) -> String:
	full_msg = str("\"", code, "\" ")
	parse = code.split(" ")
	
	if parse.size() > 10:
		return_msg = str("too many arguments")
		return return_msg
	
	match parse[0]:
		"spawn":
			spawn()
		"give":
			give()
		"kill":
			print("killing something")
		_:
			return_msg = str(full_msg, parse[0], " is not a recognized command")
			return return_msg
	
	return return_msg

func check_valid_object() -> bool:
	if parse.size() < 2:
		return false
	
	if parse[1] in Constants.OBJECTS:
		return true
	
	return false

func check_valid_spawn() -> bool:
	if parse.size() < 3:
		return false
	
	var vector_vars = parse[2].split(",")
	
	if vector_vars.size() == 3:
		var num_count := 0
		
		for variable in vector_vars:
			if variable.is_valid_float():
				num_count += 1
		
		if num_count == 3:
			return true
	return false

func spawn() -> void:
	if check_valid_object():
		if check_valid_spawn():
			return_msg = str(full_msg, "spawned ", parse[1], " at ", parse[2])
		else:
			if parse.size() > 2:
				return_msg = str(full_msg, parse[2], " is not a recognized position")
			else:
				return_msg = str(full_msg, "no position given")
	else:
		if parse.size() > 1:
			if parse[1] == "":
				return_msg = str(full_msg, "no object given")
			else:
				return_msg = str(full_msg, parse[1], " is not a recognized object")
		else:
			return_msg = str(full_msg, "no object given")
		

func check_valid_item() -> bool:
	if parse.size() < 2:
		return false
	
	if parse[1] in Constants.ITEMS:
		return true
	
	return false

func give() -> void:
	if check_valid_item():
		return_msg = str(full_msg, "added ", parse[1], " to inventory")
		print(Inventory.inventory_list)
		Inventory.add_item(load(Constants.ITEMS.get(parse[1])))
		print(Inventory.inventory_list)
	else:
		if parse.size() > 1:
			if parse[1] == "":
				return_msg = str(full_msg, "no item provided")
			else:
				return_msg = str(full_msg, parse[1], " is not a recognized item")
		else:
			return_msg = str(full_msg, "no item provided")
