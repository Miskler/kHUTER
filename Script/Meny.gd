extends Node2D

var full_scin = false
var mysic_meny = true

var dirSAV = Directory.new()
var file = File.new()

func _ready():
	$"Label2".text = "Версия игры: " + str(G.game_settings["version"])
	
	G.loadSCN = null
	
	if G.game_settings["boot_menu"] == true:
		$readi.play("di")
		$ColorRect2.show()
	
	load_game()
	$Setting/ScrollContainer/VBoxContainer/CheckBox.pressed = full_scin
	$Setting/ScrollContainer/VBoxContainer/CheckBox2.pressed = mysic_meny
	$Setting/ScrollContainer/VBoxContainer/CheckBox3.pressed = G.game_settings["boot_menu"]
	$Setting/ScrollContainer/VBoxContainer/CheckBox4.pressed = G.game_settings["bad_graphics"]
	OS.window_fullscreen = full_scin
	
	if G.game_settings["bad_graphics"] == true:
		$ColorRect.hide()
	else:
		$ColorRect.show()
	
	if mysic_meny == true:
		$AudioStreamPlayer2D.play()
	else:
		$AudioStreamPlayer2D.stop()
	#G.operation = false

func _process(_delta):
	if Input.is_action_just_pressed("FullScrin"):
		full_scin = OS.window_fullscreen
		$Setting/ScrollContainer/VBoxContainer/CheckBox.pressed = full_scin

func save_game_set():
	if not file.file_exists(G.ways["main"]): 
		file.file_exists(G.ways["main"])
	var save_dict = []
	save_dict.append(full_scin)
	save_dict.append(mysic_meny)
	save_dict.append(G.game_settings["boot_menu"])
	save_dict.append(G.game_settings["bad_graphics"])
	save_dict.append(G.ways["main"])
	save_dict.append(G.game_settings["FPS"])
	save_dict.append(G.game_settings["port"])
	save_dict.append(G.game_settings["player_name"])
	file.open(G.ways["main"], File.WRITE)
	file.store_line(to_json(save_dict))
	file.close()

func load_game():
	if not file.file_exists(G.ways["main"]): 
		file.file_exists(G.ways["main"])
		return #Error! We don't have a save to load
	file.open(G.ways["main"], File.READ)
	var data = []
	data = parse_json(file.get_as_text())
	print(data)
	if data != null:
		full_scin = data[0]
		mysic_meny = data[1]
		G.game_settings["bad_graphics"] = data[2]
		G.ways["main"] = data[3]
		G.game_settings["FPS"] = data[4]
		G.game_settings["port"] = data[5]
		G.game_settings["player_name"] = data[6]
		
		$Setting/ScrollContainer/VBoxContainer/save_path/LineEdit.text = data[3]
		$Setting/ScrollContainer/VBoxContainer/fps_limit/SpinBox.value = data[4]
		$Setting/ScrollContainer/VBoxContainer/port_server/SpinBox.value = data[5]
		$Setting/ScrollContainer/VBoxContainer/player/SpinBox.text = data[6]
		
		Engine.set_target_fps(data[4])
	file.close()
	if G.game_settings["bad_graphics"] == true:
		$ColorRect.hide()
		$Position2D/AnimatedSprite.show()
		$Position2D/ColorRect.hide()
	else:
		$ColorRect.show()
		$Position2D/AnimatedSprite.hide()
		$Position2D/ColorRect.show()

func _exit_tree():
	#G.operation = true
	save_game_set()

func pressed_play():
	$AudioStreamPlayer2D2.play()
	$Control2.show()

func pressed_exited():
	get_tree().quit()

func ysac_pressed():
	$AudioStreamPlayer2D2.play()
	save_game_set()

func linc_pressed():
	$AudioStreamPlayer2D2.play()
	OS.shell_open("https://discord.gg/UnJnGHNbBp")

func nastroici_hide_pressed():
	$AudioStreamPlayer2D2.play()
	$sett.play("hide")
	save_game_set()

func nastoici_show_pressed():
	$AudioStreamPlayer2D2.play()
	$sett.play("show")

func CheckBox_pressed_full_sren():
	$AudioStreamPlayer2D2.play()
	full_scin = $Setting/ScrollContainer/VBoxContainer/CheckBox.pressed
	OS.window_fullscreen = full_scin

func CheckBox2_pressed_aydio():
	$AudioStreamPlayer2D2.play()
	mysic_meny = $Setting/ScrollContainer/VBoxContainer/CheckBox2.pressed
	if mysic_meny == true:
		$AudioStreamPlayer2D.play()
	else:
		$AudioStreamPlayer2D.stop()

func CheckBox3_pressed_prop_ecran():
	$AudioStreamPlayer2D2.play()
	G.prop_meny_priv = $Setting/ScrollContainer/VBoxContainer/CheckBox3.pressed

func _on_AnimationPlayer_animation_finished(_anim_name):
	get_tree().change_scene("res://Sceni/rootGame.tscn")

func pressed_grafic_loy():
	$AudioStreamPlayer2D2.play()
	G.game_settings["bad_graphics"] = not G.game_settings["bad_graphics"]
	if G.game_settings["bad_graphics"] == true:
		$ColorRect.hide()
		$Position2D/AnimatedSprite.show()
		$Position2D/ColorRect.hide()
	else:
		$ColorRect.show()
		$Position2D/AnimatedSprite.hide()
		$Position2D/ColorRect.show()

func otladca_hide():
	$AudioStreamPlayer2D2.play()
	$sett.play("otladca")

func map_editor_pressed():
	$AudioStreamPlayer2D2.play()
	get_tree().change_scene("res://Sceni/LVL/editmap.tscn")

func server_main_off():
	$Control2/server.hide()
	$Control2/Control2.show()
	$AudioStreamPlayer2D2.play()

func server_main_on():
	$Control2/server.show()
	$Control2/Control2.hide()
	$AudioStreamPlayer2D2.play()

func port_server_changed(value):
	G.game_settings["port"] = value

func player_name_changed(new_text):
	G.game_settings["player_name"] = new_text

func client_off():
	$Control2/client.hide()
	$Control2/Control2.show()
	$AudioStreamPlayer2D2.play()

func client_on():
	$Control4.show()
	$AudioStreamPlayer2D2.play()
