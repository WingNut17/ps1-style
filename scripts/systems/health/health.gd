class_name Health
extends Node

signal max_health_changed(diff: float)
signal health_changed(diff: float)
signal health_depleted

@export var max_health: float = 10:
	set = set_max_health,
	get = get_max_health
@export var immortality: bool = false:
	set = set_immortality,
	get = get_immortality
@export var immortality_time: float = 0.25

var immortality_timer: Timer = null
var tween: Tween = null

@onready var health: float = max_health :
	set = set_health,
	get = get_health

func _ready() -> void:
	# Ensure the timer exists
	if immortality_timer == null:
		immortality_timer = Timer.new()
		immortality_timer.one_shot = true
		add_child(immortality_timer)
		immortality_timer.timeout.connect(_end_immortality)

func set_max_health(value: float) -> void:
	var clamped_value = max(1.0, value)
	if clamped_value != max_health:
		var difference = clamped_value - max_health
		max_health = clamped_value
		max_health_changed.emit(difference)
		
		if health > max_health:
			health = max_health
	
func get_max_health() -> float:
	return max_health

func set_immortality(value: bool):
	immortality = value
	
func get_immortality() -> bool:
	return immortality

func set_temporal_immortality(time: float) -> void:
	if immortality:
		return  # Prevent overlapping i-frames
	
	immortality = true
	immortality_timer.start(time)

func _end_immortality() -> void:
	immortality = false

func set_health(value: float) -> void:
	if value < health and immortality:
		return  # Ignore damage if immortal
	
	var clamped_value = clampf(value, 0.0, max_health)
	if clamped_value != health:
		var difference = clamped_value - health
		health = clamped_value
		health_changed.emit(difference)
		
		set_temporal_immortality(immortality_time)
		
		if health == 0:
			health_depleted.emit()

func get_health() -> float:
	return health
