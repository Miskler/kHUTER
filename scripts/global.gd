extends Node

#НОВЫЕ

var game_settings = {
	"version": "0.2.8 - Refactoring",
	"prolog": false,
	"boot_menu": false,
	"bad_graphics": false,
	"FPS": 60,
	"port": 7732,
	"render_bonus": 4,
	"player_name": "Player1234",
	"mobile": false,
	"mobile_use_all": true,
	"auto_save": 5,
	"auto_on": true,
}

@export var ways = {
	"main": "C:/Users/ПК/AppData/Roaming/Godot/app_userdata/kHUTER/SaveGame",
	"settings": "user://SaveGame/setting_data.json",
	"data_servers": "user://SaveGame/servers_data.json",
	"server": "5.44.41.50", #"127.0.0.1"
}

var player_roster = {}
var live_player_roster = {}


var start_game_params = {
	"ore": [{"andesite": 0.3}, {"copper": 0.45}, {"details": 0.45}, {"moss": 0.45}, {"ice": 0.45}, {"iron": 0.45}]
}


#СТАРЫЕ

var loadSCN

func _input(_event):
	if Input.is_action_just_pressed("FullScrin"):
		get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN if (not ((get_window().mode == Window.MODE_EXCLUSIVE_FULLSCREEN) or (get_window().mode == Window.MODE_FULLSCREEN))) else Window.MODE_WINDOWED
	elif Input.is_action_just_pressed("F5"):
		SaveLoader.save_map("Быстрое-сохранение")

func remove_recursive(path):
	var directory = DirAccess.open(path)
	
	directory.list_dir_begin() # TODOGODOT4 fill missing arguments https://github.com/godotengine/godot/pull/40547
	var file_name = directory.get_next()
	while file_name != "":
		if directory.current_is_dir():
			remove_recursive(path + "/" + file_name)
		else:
			directory.remove(file_name)
		file_name = directory.get_next()
	
	directory.remove(path)

func typeto(variable, type:int = 0):
	match type:
		TYPE_BOOL:
			return bool(variable)
		TYPE_INT:
			return int(variable)
		TYPE_FLOAT:
			return float(variable)
		TYPE_STRING:
			return str(variable)
	return variable

func name_generate(standart_name:String, path:String):
	var node = get_node_or_null(path)
	if node != null:
		var out_name = standart_name+"_1"
		while node.get_node_or_null(out_name) != null:
			out_name = standart_name+"_"+str(randf()*1000000)
		return out_name
	return false

func comparison(one, two, mode = 0):
	mode = clamp(float(mode), -1.0, 1.0)
	if typeof(one) != typeof(two): return null
	
	var result
	if mode == -1: #one<two
		if one is Vector2:
			result = one.x < two.x and one.y < two.y
		else:
			result = one < two
	elif mode == 0: #one=two
		if one is Vector2:
			result = one.x == two.x and one.y == two.y
		else:
			result = one == two
	else: #one>two
		if one is Vector2:
			result = one.x > two.x and one.y > two.y
		else:
			result = one > two
	return result


func my_id():
	if get_tree().network_peer != null:
		G.player_roster[G.game_settings["player_name"]] = get_tree().get_unique_id()
	else:
		G.player_roster[G.game_settings["player_name"]] = 1
	return G.player_roster.get(G.game_settings["player_name"])
