extends "../FileStatistics.gd"

const ICON: Texture2D = preload("../../icons/markdown.svg")

func get_extension() -> String:
	return "Markdown"

func get_color() -> Color:
	return Color.GHOST_WHITE

func get_icon() -> String:
	return ICON.resource_path
