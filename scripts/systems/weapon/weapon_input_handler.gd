class_name WeaponInputHandler
extends Node


signal shoot_requested
signal reload_requested
signal shoot_held
signal shoot_released

var weapon_stats: RangedWeaponItem


func initialize(stats: RangedWeaponItem) -> void:
	self.name = "WeaponInputHandler"
	weapon_stats = stats

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		shoot_requested.emit()
		if weapon_stats.full_auto:
			shoot_held.emit()
	elif event.is_action_pressed("reload"):
		reload_requested.emit()
	elif event.is_action_released("click"):
		if weapon_stats.full_auto:
			shoot_released.emit()
