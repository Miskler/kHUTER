extends Control

onready var Interf:Control = $"../Interf"

onready var GG = get_node("../../../../GG")

func TextureButton_pressed():
	$".".hide()
	GG.UI["osob"] = false
	Interf.show()
