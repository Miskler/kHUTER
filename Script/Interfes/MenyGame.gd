extends Control

onready var CraftMeny: Control = $"../CraftMeny" #две точки - это шаг выше по иерархии, то есть - "перейди к владельцу и в нем найди ноду Interf"
onready var Interf: Control = $"../Interf"
onready var Nadeto: Control = $"../Nadeto"
onready var MenyInter: Control = $"../MenyInter"
onready var TiLox: Control = $"../TiLox"
onready var GG = get_node("../../../../GG")

func _ready():
	if G.ru == false:
		$VBoxContainer/Button.text = "BACK"
		$VBoxContainer/Button2.text = "quit"
		$VBoxContainer/Button3.text = "load"

func _process(_delta):
	if Input.is_action_just_pressed("esc") and GG.UI["osob"] == false or $VBoxContainer/Button.pressed and GG.ymer == false and GG.UI["osob"] == false:
		if GG.UI["intermeny"] == true:
			MenyInter.hide()
			Nadeto.hide()
			CraftMeny.hide()
			Interf.show()
			GG.UI["intermeny"] = false
		
		else:
			if GG.UI["vcl"] == false:
				$".".show()
				Nadeto.hide()
				Interf.hide()
				CraftMeny.hide()
				MenyInter.hide()
				GG.UI["vcl"] = true
			
			else:
				$".".hide()
				Interf.show()
				GG.UI.vcl = false
	var file = File.new()
	if not file.file_exists(G.way):
		$VBoxContainer/Button3.hide()
	else:
		$VBoxContainer/Button3.show()

func vihot_pressed():
	Nadeto.hide()
	Interf.show()
	CraftMeny.hide()
	MenyInter.hide()
	TiLox.hide()
	$".".hide()
	get_tree().change_scene("res://Sceni/LVL/Meny.tscn")

func loud_pressed():
	$".".hide()
	Nadeto.hide()
	Interf.show()
	CraftMeny.hide()
	MenyInter.hide()
	TiLox.hide()

func _on_QAnim_animation_finished(_anim_name):
	vihot_pressed()

func _on_LoadAnim_animation_finished(_anim_name):
	loud_pressed()
