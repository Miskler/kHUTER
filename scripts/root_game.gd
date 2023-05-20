extends Node

var scene = PackedScene.new()
@onready var saveNode

@onready var SD = get_node_or_null("/root/rootGame/Node/SettingData")

func _ready():
	G.player_roster = {}
	G.live_player_roster = {}
	
	get_tree().connect("peer_disconnected", Callable(self, "player_disconnect"))
	
	if get_tree().network_peer == null:
		G.player_roster.erase(0)
		G.player_roster[1] = G.game_settings["player_name"]
		G.live_player_roster[1] = G.game_settings["player_name"]
	else:
		G.player_roster[G.my_id()] = G.game_settings["player_name"]
	
	if (get_tree().network_peer == null or get_tree().is_server()) and (G.loadSCN is String):
		print("Пользователь опеределён как сервер!")
		get_tree().paused = false
		if str(G.loadSCN).ends_with(".khuter"):
			var file = File.new()
			file.open(G.loadSCN, File.READ)
			var data = str_to_var(file.get_as_text())
			file.close()
			SaveLoader.load_map(get_path(), data)
		else:
			SaveLoader.load_map(get_path(), G.loadSCN)
		if get_node_or_null("Node/Player") == null:
			revive_player(G.my_id())
		print("Cцена инициализированна!")
	elif get_tree().network_peer != null and not get_tree().is_server():
		SaveLoader.connect("load_complete", Callable(self, "new_user_complete"))
		$connect_wait.start()
		rpc("new_user", G.my_id(), G.game_settings["player_name"])
	else:
		G.get_node("Global Interface").new_notification("Ошибка", "Не удалось загрузить карту...", Color("ddff0000"), Color("ddb50000"), 0.1)
		G.get_node("Load Screen").select("res://scenes/levels/technical/main_menu.tscn")

@rpc("any_peer") func new_user(user_id:int, user_name:String):
	G.player_roster[user_id] = user_name
	G.live_player_roster[user_id] = user_name
	
	revive_player(user_id, false)
	sms("Пользователь "+user_name+" подключился!")
	
	if get_tree().is_server():
		SaveLoader.send_map(user_id, [G.player_roster, G.live_player_roster])
func new_user_complete(complete:bool, data:Array):
	if complete:
		$connect_wait.stop()
		
		G.player_roster = data[0]
		G.live_player_roster = data[1]
		
		create_users(G.live_player_roster)
	else:
		get_tree().network_peer = null
		G.get_node("Global Interface").new_notification("Ошибка подключения", "Сервер прислал карту битой!", Color("ddff0000"), Color("ddb50000"), 0.1)
		G.get_node("Load Screen").select("res://scenes/levels/technical/main_menu.tscn")
func connect_wait():
	get_tree().network_peer = null
	G.get_node("Global Interface").new_notification("Ошибка подключения", "Сервер не смог подготовить карту для подключения.", Color("ddff0000"), Color("ddb50000"), 0.1)
	G.get_node("Load Screen").select("res://scenes/levels/technical/main_menu.tscn")


func create_users(users):
	for i in users.keys():
		revive_player(i, false)

@rpc("any_peer") func sms(text, nam = null, mode:bool = true):
	if get_node_or_null("Node/Player/Camera2D_specter") != null:
		get_node("Node/Player/Camera2D_specter/CanvasLayer/main").chat_event(text, nam)
	elif mode:
		get_node("Node/Player/Camera2D/interface/chat").chat_event(str(text))

@rpc("any_peer") func player_disconnect(id):
	if G.player_roster.has(id):
		print("Игрок отключился: " + str(id))
		if get_node_or_null("Node/Player/Camera2D_specter") != null:
			get_node("Node/Player/Camera2D_specter/CanvasLayer/main").chat_event("Игрок " + str(G.player_roster[id]) + " отключился")
		else:
			get_node("Node/Player/Camera2D/interface/chat").chat_event("Игрок " + str(G.player_roster[id]) + " отключился")
		G.player_roster.erase(id)
		if G.live_player_roster.has(id):
			G.live_player_roster.erase(id)
		if id != G.my_id() and get_node_or_null("Node/" + str(id)):
			get_node("Node/" + str(id)).queue_free()

@rpc("any_peer") func specter() -> Node:
	var spect = load("res://scenes/entities/controlled/specter.tscn").instantiate()
	spect.global_position = get_node("Node/Player").global_position
	get_node("Node/Player").queue_free()
	await get_tree().idle_frame
	spect.name = "Player"
	get_node("Node").add_child(spect)
	return spect

@rpc("any_peer") func revive_player(id:int, send_notification:bool = true):
	SD = get_node("Node/SettingData")
	if send_notification:
		if get_node_or_null("Node/Player/Camera2D_specter") != null and id != G.my_id():
			get_node("Node/Player/Camera2D_specter/CanvasLayer/main").chat_event("Игрок " + str(G.player_roster[id]) + " возрадился")
		elif get_node_or_null("Node/Player/Camera2D/interface/chat") != null and id != G.my_id():
			get_node("Node/Player/Camera2D/interface/chat").chat_event("Игрок " + str(G.player_roster[id]) + " возрадился")
	if id == G.my_id():
		if get_node_or_null("Node/Player") != null:
			get_node("Node/Player").queue_free()
		var player = load("res://scenes/entities/controlled/player.tscn").instantiate()
		await get_tree().idle_frame
		player.global_position = SD.map_settings["creation_position"]
		get_node("Node").add_child(player)
		player.name = "Player"
	else:
		var player_puppet = load("res://scenes/entities/controlled/player_puppet.tscn").instantiate()
		player_puppet.name = str(id)
		player_puppet.local_name = str(G.player_roster[id])
		await get_tree().idle_frame
		get_node("Node").add_child(player_puppet)
	
	if id == 0:
		G.live_player_roster[1] = G.player_roster[1]
	else:
		G.live_player_roster[id] = G.player_roster[id]

@rpc("any_peer") func player_died(id:int) -> void:
	print("Игрок умер: " + str(id))
	G.live_player_roster.erase(id)
	if get_node_or_null("Node/Player/Camera2D_specter") != null:
		get_node("Node/Player/Camera2D_specter/CanvasLayer/main").chat_event("Игрок " + str(G.player_roster[id]) + " уничтожен")
	else:
		get_node("Node/Player/Camera2D/interface/chat").chat_event("Игрок " + str(G.player_roster[id]) + " уничтожен")
	
	if id != G.my_id() and get_node_or_null("Node/" + str(id)) != null:
		get_node("Node/" + str(id)).queue_free()

@rpc("any_peer") func file_select(nodes, player_roster, live_player_roster):
	print("Загрузка полученной карты размером " + str(nodes.size()) + " нод.")
	
	SaveLoader.set_scene(nodes)
	
	G.player_roster = player_roster
	G.live_player_roster = live_player_roster
	
	for i in range(player_roster.size()):
		var user_id = player_roster.keys()[i]
		if user_id != G.my_id():
			breakpoint
			#send(user_id, player_roster[user_id])
	
	await get_tree().idle_frame
	
	revive_player(G.my_id())
	
	await get_tree().idle_frame
	
	breakpoint
	#spavn_players()

@rpc("any_peer") func game_win(titre:String, text:String, audio:bool = true):
	var v = load("res://scenes/interface/win_game.tscn").instantiate()
	add_child(v)
	get_node("win/ColorRect2/Label").text = titre
	get_node("win/ColorRect2/RichTextLabel").text = text
	if audio:
		get_node("win/AudioStreamPlayer").play()

@rpc("any_peer") func event_state(path, data = null):
	if get_node_or_null(path) != null and path.begins_with("/root/rootGame/Node") and data != null:
		get_node(path).event_state(data)

#Позиция, поворот, текстура, урон, притяжение к земле
@rpc("any_peer") func create_bullet(gan, bullet, pos, rot = 0, texture:String = "res://textures/ui/items/blebreskinproj.png", damage = 1, attraction = 0, speed = 100, mode:bool = false, output:int = 0, source:Node = null) -> Node:
	#SD = get_node("/root/rootGame/Node/SettingData")
	var bullet_load = load("res://scenes/entities/supporting/bullet.tscn").instantiate()
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

@rpc("any_peer") func drop_item(data:Dictionary = {}, name_drop:String = G.name_generate("SlotInWorld", "/root/rootGame/Node")) -> Node:
	var node = load("res://scenes/entities/supporting/world_item.tscn").instantiate()
	
	for key in data.keys():
		node.set(key, data[key])
	
	node.name = name_drop
	
	get_node("Node").add_child(node)
	return node

@rpc("any_peer") func damage(path, setting_bullet):
	get_node(path).damage(setting_bullet)
