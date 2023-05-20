@tool
extends Control

const ChartData: Script = preload("./ChartData.gd")

@export var radius: float: float = 50.0: set = set_radius

var series: Dictionary

func _init() -> void:
	clip_contents = true

func clear() -> void:
	series.clear()
	update()

func add_data(data: ChartData) -> void:
	series[data.name] = data
	update()

func remove_data(name: String) -> void:
	series.erase(name)
	update()

func set_radius(value: float) -> void:
	radius = max(0, value)
	self.custom_minimum_size = Vector2.ONE * radius * 2

func draw_filled_arc(center: Vector2, radius: float, start_angle: float, end_angle: float,
	point_count: int, color: Color, antialiased: bool = false
) -> void:
	var points: PackedVector2Array = []
	points.push_back(center)
	
	for i in range(point_count + 1):
		var angle_point: float = start_angle + i * (end_angle - start_angle) / point_count
		points.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)
	draw_polygon(points, [color], [], null, null, antialiased)

func _draw() -> void:
	var charts_data: Array = series.values()
	var total: float = 0.0
	for data in charts_data:
		total += data.value
	
	var center: Vector2 = size / 2.0
	var start_angle: float = 0.0
	var i: int
	for data in charts_data:
		var percent: float = data.value / total
		var end_angle: float = start_angle - percent * 2 * PI
		draw_filled_arc(
			center,
			radius,
			start_angle,
			end_angle,
			30 * percent + 2,
			data.color,
			true
		)
		start_angle = end_angle
	var outline_width: float = 1.2
	
	if not get_constant("dark_theme", "Editor"):
		draw_arc(center, radius - outline_width / 2, 0.0, 2 * PI, 32, Color.LIGHT_SLATE_GRAY, 1.5, true)

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_THEME_CHANGED:
			update()
