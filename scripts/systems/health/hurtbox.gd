class_name HurtBox
extends Area3D


signal received_damage(damage: int, hb_name: String)

@export var health: Health
@export_enum("NPC", "object") var type: String = "NPC"


func _ready() -> void:
	connect("area_entered", _on_area_entered)

func _on_area_entered(hitbox: Area3D) -> void:
	if hitbox is HitBox:
		var hb := hitbox as HitBox
		health.health -= hb.damage
		received_damage.emit(hb.damage, hb.get_parent().name)

func take_damage_from_hitscan(damage: int, source_name: String = "Hitscan") -> void:
	health.health -= damage
	received_damage.emit(damage, source_name)
