class_name WeaponStats
extends Resource


@export_category("identification")
@export var weapon_name: String
@export var weapon_model: PackedScene
@export_enum("Melee", "Gun") var type: String
@export var full_auto: bool

@export_category("ammo")
@export var current_ammo_reserves: int
@export var max_magazine_ammo: int
@export var current_magazine_ammo: int

@export_category("specifications")
@export var shoot_damage: int = 1
@export var shoot_speed: float = 1.0
@export var reload_time: float = 2.0
@export var shoot_distance: float = 10.0

@export_category("audio")
@export var shoot_sound: AudioStreamOggVorbis
@export var no_ammo_sound: AudioStreamOggVorbis
@export var reload_sound: AudioStreamOggVorbis

@export_category("animations")
@export var recoil_amount: float
