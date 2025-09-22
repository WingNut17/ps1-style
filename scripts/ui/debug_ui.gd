extends MarginContainer

@onready var rich_text_label: RichTextLabel = %RichTextLabel
@onready var text_edit: TextEdit = %TextEdit

var code: String

func _ready() -> void:
	text_edit.text_changed.connect(_on_text_changed)
	rich_text_label.text = ""

func _on_text_changed() -> void:
	code = text_edit.text
	
	for i in range(code.length()):
		var current_char = code[i]

		if current_char == "
":
			code = code.strip_escapes()
			push_debug_message()

func push_debug_message() -> void:
	text_edit.clear()
	rich_text_label.text += str(Debug.parse_code(code), "\n")
