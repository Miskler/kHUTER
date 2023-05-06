extends Button

onready var pupaanim = $"../../sett"
onready var Au = $"../../AudioStreamPlayer2D2"

func _pressed():
	Au.play()
	pupaanim.play_backwards("otladca")
