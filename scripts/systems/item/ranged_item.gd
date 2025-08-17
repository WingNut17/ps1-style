class_name RangedWeaponItem
extends Item

signal update_ammo

var _magazine_ammo: int = 0

@export_category("Ammo") 
@export var ammo_type: String 
@export var magazine_ammo: int:
	get:
		return _magazine_ammo
	set(value):
		_magazine_ammo = value
		update_ammo.emit()
	
@export var max_magazine_ammo: int 

@export_category("Specifications") 
@export var full_auto: bool 
@export var shoot_damage: int = 1 
@export var shoot_speed: float = 1.0 
@export var reload_time: float = 2.0 
@export var shoot_range: float = 10.0 

@export_category("Audio") 
@export var shoot_sound: AudioStreamOggVorbis 
@export var no_ammo_sound: AudioStreamOggVorbis 
@export var reload_sound: AudioStreamOggVorbis 

@export_category("Animations") 
@export var shoot_anim: StringName = "shoot" 
@export var no_ammo_anim: StringName = "no_ammo" 
@export var reload_anim: StringName = "reload" 
@export var recoil_amount: float 

var can_shoot: bool = true
var currently_full_auto: bool = false

func initialize(holder: Node3D) -> void:
	super.initialize(holder) # <-- important
	if full_auto:
		item_container.full_auto_timer.wait_time = shoot_speed
		item_container.full_auto_timer.timeout.connect(_on_full_auto_timer_timeout)

func on_primary_action() -> void: 
	try_shoot()

func try_shoot() -> void:
	can_shoot = !item_container.item_animation.is_playing() 
	
	if magazine_ammo > 0 and can_shoot: 
		shoot() 
	elif can_shoot and magazine_ammo == 0: 
		item_container.item_animation.play(no_ammo_anim) 
		item_container.item_audio.pitch_scale = randf_range(0.9, 1.1) 
		item_container.item_audio.stream = no_ammo_sound 
		item_container.item_audio.play()

func on_full_auto_start() -> void:
	currently_full_auto = true
	try_shoot()

func on_full_auto_stop() -> void:
	currently_full_auto = false
	item_container.full_auto_timer.stop()

func shoot() -> void:
	item_container.item_animation.speed_scale = 1.0 / shoot_speed
	item_container.item_animation.play(shoot_anim)

	if item_container.shoot_mesh:
		item_container.shoot_mesh.visible = true

	item_container.item_audio.pitch_scale = randf_range(0.9, 1.1)
	item_container.item_audio.stream = shoot_sound
	item_container.item_audio.play()

	HitscanSystem.perform_hitscan(item_container.camera, shoot_range, shoot_damage)
	item_container.head.rotation_degrees.x += randi_range(1, 4)

	if full_auto:
		item_container.full_auto_timer.start()

	magazine_ammo -= 1

func on_reload() -> void: 
	can_shoot = !item_container.item_animation.is_playing() 
	
	var ammo_available = Inventory.get_ammo_count(ammo_type) 
	
	var needed = max_magazine_ammo - magazine_ammo  
	
	if can_shoot and needed > 0 and ammo_available > 0: 
		var bullets_to_add = min(needed, ammo_available) 
		Inventory.remove_ammo(ammo_type, bullets_to_add) 
		magazine_ammo += bullets_to_add 
		reload() 

func reload() -> void: 
	item_container.item_animation.speed_scale = 1/reload_time 
	item_container.item_animation.play(reload_anim) 
	
	item_container.item_audio.pitch_scale = randf_range(0.9, 1.1) 
	item_container.item_audio.stream = reload_sound 
	item_container.item_audio.play()

func _on_full_auto_timer_timeout() -> void:
	if currently_full_auto:
		item_container.full_auto_timer.start()
		try_shoot()
