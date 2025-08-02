class_name AmmoSystem
extends Node


signal ammo_changed

var gun_stats: WeaponStats
var ammo_label: Label


func initialize(stats: WeaponStats, label: Label) -> void:
	self.name = "AmmoSystem"
	gun_stats = stats
	ammo_label = label
	update_ammo_display()

func can_shoot() -> bool:
	return gun_stats.current_magazine_ammo > 0

func is_magazine_empty() -> bool:
	return gun_stats.current_magazine_ammo == 0

func can_reload() -> bool:
	return gun_stats.current_ammo_reserves > 0 and gun_stats.current_magazine_ammo != gun_stats.max_magazine_ammo

func can_shoot_currently() -> bool:
	# This would need to check with animation manager - removed since we handle this in main weapon class
	return true

func consume_ammo() -> void:
	gun_stats.current_magazine_ammo -= 1
	update_ammo_display()
	ammo_changed.emit()

func reload() -> void:
	var difference = gun_stats.max_magazine_ammo - gun_stats.current_magazine_ammo
	var bullets_adding = clampi(difference, 0, gun_stats.current_ammo_reserves)
	
	gun_stats.current_ammo_reserves -= bullets_adding
	gun_stats.current_magazine_ammo += bullets_adding
	
	update_ammo_display()
	ammo_changed.emit()

func update_ammo_display() -> void:
	if ammo_label:
		ammo_label.text = "Ammo: " + str(gun_stats.current_ammo_reserves) + "/" + str(gun_stats.current_magazine_ammo)
