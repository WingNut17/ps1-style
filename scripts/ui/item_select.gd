extends PanelContainer


@onready var use_button: Button = %UseButton
@onready var equip_button: Button = %EquipButton


func _on_back_button_pressed() -> void:
	self.visible = !self.visible


func _on_equip_button_pressed() -> void:
	pass # Replace with function body.


func _on_use_button_pressed() -> void:
	pass # Replace with function body.
