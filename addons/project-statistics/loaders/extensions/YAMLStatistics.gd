extends "../FileStatistics.gd"

const ICON: Texture2D = preload("../../icons/yaml.svg")

func get_extension() -> String:
	return "YAMl"
	
func get_color() -> Color:
	return Color.MEDIUM_PURPLE

func get_icon() -> String:
	return ICON.resource_path

func is_comment(line: String) -> bool:
	return line.strip_edges().begins_with("#")
