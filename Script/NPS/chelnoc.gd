extends KinematicBody2D

var vec = Vector2()
var y = 100

func _physics_process(_delta):
	if !is_on_floor():
		vec.y = y
	
	vec = move_and_slide(vec)
