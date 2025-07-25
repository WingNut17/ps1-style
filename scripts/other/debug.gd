extends PanelContainer

@onready var property_container = %VBoxContainer
#var property
var fps : float

func _ready():
	visible = true # dev branch on by default
	# refer to itself in the global singleton
	Global.debug = self
	#add_debug_property("fps", "fps")

func _process(delta):
	if visible:
		# fps = float("%.2f" % (1.0/delta)) # every update
		fps = Engine.get_frames_per_second() # every second
		#property.text = property.name + ": " + str(fps)

func _input(event):
	if event.is_action_pressed("dev_log"):
		visible = !visible

func add_property(title: String, value, order):
	var target
	target = property_container.find_child(title, true, false)
	if !target:
		target = Label.new()
		property_container.add_child(target)
		target.name = title
		target.text = target.name + ": " + str(value)
	elif visible:
		target.text = title + ": " + str(value)
		property_container.move_child(target, order)
		
#func add_debug_property(title: String,value):
	#property = Label.new()
	#property_container.add_child(property)
	#property.name = title
	#property.text = property.name + " " + value
