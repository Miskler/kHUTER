extends Node

var scene = PackedScene.new()
onready var saveNode

onready var SD = get_node_or_null("/root/rootGame/Node/SettingData")

func _ready():
	G.player_roster = {}
	G.live_player_roster = {}
	
	get_tree().connect("network_peer_disconnected", self, "player_disconnect")
	
	if get_tree().network_peer == null:
		G.player_roster.erase(0)
		G.player_roster[1] = G.game_settings["player_name"]
		G.live_player_roster[1] = G.game_settings["player_name"]
	else:
		G.player_roster[G.my_id()] = G.game_settings["player_name"]
	
	if get_tree().network_peer == null or get_tree().is_network_server() == true:
		print("Пользователь опеределён как сервер!")
		get_tree().paused = false
		if str(G.loadSCN).ends_with(".khuter"):
			var file = File.new()
			file.open(G.loadSCN, File.READ)
			var data = str2var(file.get_as_text())
			file.close()
			SaveLoader.load_map(get_path(), data)
		else:
			SaveLoader.load_map(get_path(), G.loadSCN)
		if get_node_or_null("Node/Player") == null:
			revive_player(G.my_id())
		print("Cцена инициализированна!")
	elif get_tree().network_peer != null:
		$Timer.start()

func idl():
	print("Запуск клиента...")
	get_map()

func get_map():
	print("Отправлен запрос на получения карты...")
	G.rpc_id(1, "_player_connected", G.my_id(), G.game_settings["player_name"])
	G.get_node("Load Screen").event_p(5)

func spavn_players():
	for i in G.player_roster.keys():
		if G.live_player_roster.has(i) and str(i) != str(G.my_id()):
			print("Добавление новой пешки на карту: " + str(i))
			var GG = load("res://Scenes/NPS/Player_puppet.res").instance()
			GG.name = str(i)
			GG.local_name = str(G.player_roster[i])
			yield(get_tree(), "idle_frame")
			get_node("Node").add_child(GG)

func get_player(id):
	print("Получение информации о пользователе: " + str(id))
	rpc_id(id, "send", get_tree().get_network_unique_id(), G.game_settings["player_name"])

remote func send(user_id, user_name):
	print("Отправка информации о мне по запросу: " + str(user_id))
	rpc_id(user_id, "player_connect_server", get_tree().get_network_unique_id(), G.game_settings["player_name"])
	if !G.player_roster.has(user_id):
		G.player_roster[user_id] = user_name
		G.live_player_roster[user_id] = user_name
		if get_node_or_null("Node/Player/Camera2D_specter") != null:
			get_node("Node/Player/Camera2D_specter/CanvasLayer/main").chat_event("Игрок " + str(user_name) + " подключился")
		elif get_node_or_null("Node/Player/Camera2D") != null:
			get_node("Node/Player/Camera2D/interface/chat").chat_event("Игрок " + str(user_name) + " подключился")

remote func sms(text, nam = null, mode:bool = true):
	if get_node_or_null("Node/Player/Camera2D_specter") != null:
		get_node("Node/Player/Camera2D_specter/CanvasLayer/main").chat_event(text, nam)
	elif mode:
		get_node("Node/Player/Camera2D/interface/chat").chat_event(str(text))

var id_d
var p_name_d

remote func player_connect_server(id, p_name):
	id_d = id
	p_name_d = p_name
	G.player_roster[id] = p_name
	G.live_player_roster[id] = p_name
	if get_node_or_null("Node/Player/Camera2D_specter") != null:
		get_node("Node/Player/Camera2D_specter/CanvasLayer/main").chat_event("Игрок " + str(p_name) + " подключился")
	elif get_node_or_null("Node/Player/Camera2D") != null:
		get_node("Node/Player/Camera2D/interface/chat").chat_event("Игрок " + str(p_name) + " подключился")
	$Timer2.start()

remote func player_disconnect(id):
	if G.player_roster.has(id):
		print("Игрок отключился: " + str(id))
		if get_node_or_null("Node/Player/Camera2D_specter") != null:
			get_node("Node/Player/Camera2D_specter/CanvasLayer/main").chat_event("Игрок " + str(G.player_roster[id]) + " отключился")
		else:
			get_node("Node/Player/Camera2D/interface/chat").chat_event("Игрок " + str(G.player_roster[id]) + " отключился")
		G.player_roster.erase(id)
		if G.live_player_roster.has(id):
			G.live_player_roster.erase(id)
		if id != get_tree().get_network_unique_id() and get_node_or_null("Node/" + str(id)):
			get_node("Node/" + str(id)).queue_free()

remote func specter():
	var spect = load("res://scenes/entities/controlled/specter.tscn").instance()
	spect.global_position = get_node("Node/Player").global_position
	get_node("Node/Player").queue_free()
	yield(get_tree(), "idle_frame")
	spect.name = "Player"
	get_node("Node").add_child(spect)

remote func revive_player(id):
	SD = get_node("Node/SettingData")
	if get_node_or_null("Node/Player/Camera2D_specter") != null and id != G.my_id():
		get_node("Node/Player/Camera2D_specter/CanvasLayer/main").chat_event("Игрок " + str(G.player_roster[id]) + " возрадился")
	elif get_node_or_null("Node/Player/Camera2D/interface/chat") != null and id != G.my_id():
		get_node("Node/Player/Camera2D/interface/chat").chat_event("Игрок " + str(G.player_roster[id]) + " возрадился")
	if id == G.my_id():
		if get_node_or_null("Node/Player") != null:
			get_node("Node/Player").queue_free()
		var player = load("res://scenes/entities/controlled/player.tscn").instance()
		yield(get_tree(), "idle_frame")
		player.global_position = SD.map_settings["creation_position"]
		get_node("Node").add_child(player)
		player.name = "Player"
		yield(get_tree(), "idle_frame")
	else:
		var player_puppet = load("res://scenes/entities/controlled/player_puppet.tscn").instance()
		player_puppet.name = str(id)
		player_puppet.local_name = str(G.player_roster[id])
		yield(get_tree(), "idle_frame")
		get_node("Node").add_child(player_puppet)
	
	if id == 0:
		G.live_player_roster[1] = G.player_roster[1]
	else:
		G.live_player_roster[id] = G.player_roster[id]

remote func player_died(id):
	print("Игрок умер: " + str(id))
	G.live_player_roster.erase(id)
	if get_node_or_null("Node/Player/Camera2D_specter") != null:
		get_node("Node/Player/Camera2D_specter/CanvasLayer/main").chat_event("Игрок " + str(G.player_roster[id]) + " умер")
	else:
		get_node("Node/Player/Camera2D/interface/chat").chat_event("Игрок " + str(G.player_roster[id]) + " умер")
	
	if id != get_tree().get_network_unique_id() and get_node_or_null("Node/" + str(id)) != null:
		get_node("Node/" + str(id)).queue_free()

remote func file_select(nodes, pl_rs, l_pl_rs):
	print("Загрузка полученной карты размером " + str(nodes.size()) + " нод.")
	G.get_node("Load Screen").event_p(10)
	yield(get_tree(), "idle_frame")
	
	SaveLoader.set_scene(nodes)
	
	G.player_roster = pl_rs
	G.live_player_roster = l_pl_rs
	
	for i in range(pl_rs.size()):
		var user_id = pl_rs.keys()[i]
		if user_id != get_tree().get_network_unique_id():
			send(user_id, pl_rs[user_id])
	
	yield(get_tree(), "idle_frame")
	
	revive_player(G.my_id())
	
	yield(get_tree(), "idle_frame")
	
	spavn_players()

remote func game_win(titre, text, audio:bool = true):
	var v = load("res://scenes/interface/win_game.tscn").instance()
	add_child(v)
	get_node("win/ColorRect2/Label").text = titre
	get_node("win/ColorRect2/RichTextLabel").text = text
	if audio:
		get_node("win/AudioStreamPlayer").play()

remote func event_state(path, data = null):
	if get_node_or_null(path) != null and path.begins_with("/root/rootGame/Node") and data != null:
		get_node(path).event_state(data)

remote func create_bullet(gan, bullet, pos, rot = 0, texture = "res://textures/ui/items/blebreskinproj.png", damage = 1, attraction = 0, speed = 100, mode:bool = false, output:int = 0, source:Node = null): #Позиция, поворот, текстура, урон, притяжение к земле
	#SD = get_node("/root/rootGame/Node/SettingData")
	var bullet_load = load("res://scenes/entities/supporting/bullet.tscn").instance()
	bullet_load.global_position = pos
	bullet_load.rotation = rot
	
	bullet_load.setting_bullet["texture"] = texture
	bullet_load.setting_bullet["damage"] = damage
	bullet_load.setting_bullet["attraction"] = attraction
	bullet_load.setting_bullet["speed"] = speed
	bullet_load.setting_bullet["instantly"] = mode
	bullet_load.setting_bullet["source"] = source
	bullet_load.setting_bullet["output"] = output
	
	bullet_load.gan = gan
	bullet_load.bullet = bullet
	
	get_node("Node").add_child(bullet_load)
	return bullet_load

remote func create_item(item, data:Dictionary = {}):
	var node = load(item).instance()
	
	for key in data.keys():
		node.set(key, data[key])
	
	node.name = G.name_generate("SlotInWorld", "/root/rootGame/Node")
	
	get_node("Node").add_child(node)
	return node


func _on_Timer2_timeout():
	print("Добавление новой пешки на карту: " + str(id_d))
	var GG = load("res://Scenes/NPS/Player_puppet.res").instance()
	GG.name = str(id_d)
	GG.local_name = str(p_name_d)
	yield(get_tree(), "idle_frame")
	get_node("Node").add_child(GG)
