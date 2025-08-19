class_name RangedWeaponItem
extends Item
## Gun resource that extends an Item resource.


signal update_ammo

var _magazine_ammo: int = 0

@export_category("Ammo") 
@export_enum("9mm","ar","magnum","50cal","sniper","shotgun") var ammo_type: String ## Used to identify which ammo type to use
@export var magazine_ammo: int: ## How much ammo is currently in the gun
	get:
		return _magazine_ammo
	set(value):
		_magazine_ammo = value
		update_ammo.emit()
@export var max_magazine_ammo: int  ## Max ammount of ammo the gun can hold in a magazine

@export_category("Specifications") 
@export var full_auto: bool ## Is the weapon full auto
@export var bullet_count: int = 1 ## How many hitscans are ran each shot
@export var spread: float = 2.5 ## What degree the bullets will spread from the middle of the screen
@export var shoot_damage: int = 1  ## Damage of each shot
@export var shoot_speed: float = 1.0 ## How many seconds must be taken between each shot
@export var reload_time: float = 2.0 ## Time to reload
@export var shoot_range: float = 10.0  ## Range of the hitscan

@export_category("Audio") 
@export var shoot_sound: AudioStreamOggVorbis ## Sound when shot
@export var no_ammo_sound: AudioStreamOggVorbis  ## Sound when no ammo left
@export var reload_sound: AudioStreamOggVorbis ## Sound when reloaded

@export_category("Animations") 
@export var reload_anim: StringName = "reload" ## Reload animation name
@export var recoil_amount: float = 1.0 ## Amount of recoil on shoot animations

var can_shoot: bool = true
var currently_shooting: bool = false
var currently_full_auto: bool = false


func initialize(holder: Node3D) -> void:
	super.initialize(holder)
	
	item_container.primary_timer.wait_time = shoot_speed
	if !item_container.primary_timer.timeout.is_connected(_on_shoot_timer_timeout):
		item_container.primary_timer.timeout.connect(_on_shoot_timer_timeout)

func on_primary_action() -> void: 
	try_shoot()

func try_shoot() -> void:
	can_shoot = !currently_shooting and !item_container.item_animation.is_playing()
	
	if magazine_ammo > 0 and can_shoot: 
		shoot() 
	elif can_shoot and magazine_ammo == 0: 
		item_container.item_audio.stream = no_ammo_sound 
		item_container.item_audio.play_audio()

func on_full_auto_start() -> void:
	currently_full_auto = true
	try_shoot()

func on_full_auto_stop() -> void:
	currently_full_auto = false

func shoot() -> void:
	item_container.item_node.shoot()
	item_container.item_audio.stream = shoot_sound
	item_container.item_audio.play_audio()
	
	if bullet_count > 1:
		for i in range(bullet_count):
			HitscanSystem.perform_hitscan(item_container.camera, shoot_range, shoot_damage, spread)
	else:
		HitscanSystem.perform_hitscan(item_container.camera, shoot_range, shoot_damage, spread)
	
	var camera_recoil = Vector3(randf_range(5,10), randf_range(-2,2), randf_range(-5,5)) * recoil_amount
	item_container.camera.rotation_degrees += camera_recoil
	item_container.head.rotation_degrees.x += randi_range(1, 4) * recoil_amount
	
	var gun_recoil = Vector3(randf_range(-3,3), randf_range(-5,5), randf_range(-40,-35)) * recoil_amount
	item_container.item_pos.rotation_degrees += gun_recoil
	item_container.item_pos.position += Vector3(randf_range(-0.05,0.05), randf_range(0.1,0.15), randf_range(0.1,0.15)) * recoil_amount
	
	item_container.primary_timer.start()
	magazine_ammo -= 1
	currently_shooting = true

func on_reload() -> void: 
	can_shoot = !currently_shooting and !item_container.item_animation.is_playing()
	
	var ammo_available = Inventory.get_ammo_count(ammo_type) 
	
	var needed = max_magazine_ammo - magazine_ammo  
	
	if can_shoot and needed > 0 and ammo_available > 0: 
		var bullets_to_add = min(needed, ammo_available) 
		Inventory.remove_ammo(ammo_type, bullets_to_add) 
		magazine_ammo += bullets_to_add 
		reload() 

func reload() -> void: 
	if reload_time:
		item_container.item_animation.speed_scale = 1/reload_time
	
	item_container.item_animation.play(reload_anim) 
	
	item_container.item_audio.stream = reload_sound 
	item_container.item_audio.play_audio()

func _on_shoot_timer_timeout() -> void:
	currently_shooting = false
	if currently_full_auto:
		try_shoot()

func on_item_equip() -> void:
	super()
	item_container.item_audio.stream = reload_sound 
	item_container.item_audio.play_audio()
