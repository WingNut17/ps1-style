class_name MeleeWeaponItem
extends Item


@export_category("specifications")
@export var damage: int = 1
@export var speed: float = 1.0
@export var range: float = 1.0

@export_category("audio")
@export var swing_sound: AudioStreamOggVorbis

@export_category("animations")
@export var attack_anim: StringName = "attack"
@export var equip_anim: StringName = "equip"
