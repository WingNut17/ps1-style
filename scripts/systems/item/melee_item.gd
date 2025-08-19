class_name MeleeWeaponItem
extends Item


@export_category("specifications")
@export var attack_damage: int = 1
@export var attack_speed: float = 1.0
@export var attack_range: float = 1.5
@export var full_auto: bool = true

@export_category("audio")
@export var swing_sound: AudioStreamOggVorbis

@export_category("animations")
@export var attack_anim: StringName = "knife_attack"
@export var equip_anim: StringName = "equip"

var can_attack: bool = true
var currently_full_auto: bool = false
var currently_attacking: bool = false


func initialize(holder: Node3D) -> void:
	super.initialize(holder)
	
	item_container.primary_timer.wait_time = attack_speed
	if !item_container.primary_timer.timeout.is_connected(_on_attack_timer_timeout):
		item_container.primary_timer.timeout.connect(_on_attack_timer_timeout)

func on_primary_action() -> void: 
	try_attack()

func try_attack() -> void:
	can_attack = !item_container.item_animation.is_playing()
	
	if can_attack:
		attack()

func attack() -> void:
	if attack_speed:
		item_container.item_animation.speed_scale = 1/attack_speed
	
	item_container.item_animation.play(str("knife_attack", randi_range(1,3)))
	
	item_container.item_audio.stream = swing_sound
	item_container.item_audio.play_audio()
	
	HitscanSystem.perform_hitscan(item_container.camera, attack_range, attack_damage)
	
	item_container.primary_timer.start()
	currently_attacking = true

func on_full_auto_start() -> void:
	currently_full_auto = true
	try_attack()

func on_full_auto_stop() -> void:
	currently_full_auto = false

func _on_attack_timer_timeout() -> void:
	currently_attacking = false
	if currently_full_auto:
		try_attack()
