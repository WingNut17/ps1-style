class_name Weapon
extends Node3D


@export var head: Node3D
@export var camera: Camera3D
@export var weapon_pos: Marker3D
@export var ammo_label: Label
@export var weapon_stats: WeaponStats

var input_handler: WeaponInputHandler
var audio_manager: WeaponAudioManager
var animation_manager: WeaponAnimationManager
var hitscan_system: HitscanSystem
var ammo_system: AmmoSystem


func _ready() -> void:
	setup_components()
	connect_signals()

func setup_components() -> void:
	# Initialize all weapon components
	input_handler = WeaponInputHandler.new()
	audio_manager = WeaponAudioManager.new()
	animation_manager = WeaponAnimationManager.new()
	hitscan_system = HitscanSystem.new()
	ammo_system = AmmoSystem.new()
	
	# Add components as children
	add_child(input_handler)
	add_child(audio_manager)
	add_child(animation_manager)
	add_child(hitscan_system)
	add_child(ammo_system)
	var weapon_node = weapon_stats.weapon_model.instantiate()
	weapon_pos.add_child(weapon_node)
	
	# Initialize components with weapon data and scene nodes
	input_handler.initialize(weapon_stats)
	ammo_system.initialize(weapon_stats, ammo_label)
	audio_manager.initialize(weapon_stats)
	animation_manager.initialize(weapon_stats, weapon_node, camera, head)
	hitscan_system.initialize(weapon_stats)

func connect_signals() -> void:
	input_handler.shoot_requested.connect(_on_shoot_requested)
	input_handler.reload_requested.connect(_on_reload_requested)
	input_handler.shoot_held.connect(_on_shoot_held)
	input_handler.shoot_released.connect(_on_shoot_released)
	ammo_system.ammo_changed.connect(_on_ammo_changed)

func _on_shoot_requested() -> void:
	if can_shoot():
		shoot()
	elif ammo_system.is_magazine_empty():
		audio_manager.play_no_ammo_sound()

func _on_shoot_held() -> void:
	# Start full auto after first shot
	animation_manager.start_full_auto()

func _on_shoot_released() -> void:
	# Stop full auto
	animation_manager.stop_full_auto()

func attempt_full_auto_shot() -> void:
	# This is called by the animation manager's full auto timer
	if can_shoot():
		shoot()

func can_shoot() -> bool:
	return ammo_system.can_shoot() and animation_manager.can_shoot_currently()

func _on_reload_requested() -> void:
	if ammo_system.can_reload() and animation_manager.can_shoot_currently():
		reload()

func shoot() -> void:
	hitscan_system.perform_hitscan(camera)
	animation_manager.play_shoot_animation()
	audio_manager.play_shoot_sound()
	ammo_system.consume_ammo()

func reload() -> void:
	if !animation_manager.can_shoot_currently():
		return
	
	animation_manager.play_reload_animation()
	audio_manager.play_reload_sound()
	ammo_system.reload()

func _on_ammo_changed() -> void:
	pass
