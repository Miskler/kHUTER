extends "../FileStatistics.gd"

const ICON: Texture2D = preload("../../icons/json.svg")

func get_extension() -> String:
	return "JSON"

func get_color() -> Color:
	return Color.GOLD

func get_icon() -> String:
	return ICON.resource_path
