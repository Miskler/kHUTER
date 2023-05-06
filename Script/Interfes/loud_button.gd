extends Button

onready var pupaanim = $"../../AnimationPlayer2"
onready var Meny = $"../../ColorRect2"
onready var Au = $"../../AudioStreamPlayer2D2"

func _pressed():
	Au.play()
	Meny.show()
	pupaanim.play("zatem")

func animation_finished_load(_anim_name):
	G.load_game()
	get_tree().paused = false
