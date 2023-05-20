@tool
extends PanelContainer

func _ready() -> void:
	set("theme_override_styles/panel", get_stylebox("Content", "EditorStyles"))
