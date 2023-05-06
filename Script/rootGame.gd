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
		if str(G.loadSCN).ends_with(".huter"):
			var file = File.new()
			file.open(G.loadSCN, File.READ)
			var data = str2var(file.get_as_text())
			file.close()
			set_scene(data)
		else:
			set_scene(G.loadSCN)
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
	var spect = load("res://Scenes/NPS/Specter.res").instance()
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
		var player = load("res://Scenes/NPS/Player.res").instance()
		yield(get_tree(), "idle_frame")
		player.global_position = SD.map_settings["creation_position"]
		get_node("Node").add_child(player)
		player.name = "Player"
		yield(get_tree(), "idle_frame")
	else:
		var player_puppet = load("res://Scenes/NPS/Player_puppet.res").instance()
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
	
	set_scene(nodes)
	
	G.player_roster = pl_rs
	G.live_player_roster = l_pl_rs
	
	for i in range(pl_rs.size()):
		var user_id = pl_rs.keys()[i]
		if user_id != get_tree().get_network_unique_id():
			send(user_id, pl_rs[user_id])
	
	yield(get_tree(), "idle_frame")
	
	revive_player(get_tree().get_network_unique_id())
	
	yield(get_tree(), "idle_frame")
	
	spavn_players()

func ready_script_started(root, ignored):
	for node in root.get_children():
		var path = node.get_path()
		if !path in ignored and node.has_method("_ready"):
			node._ready()
		ready_script_started(node, ignored)

func connect_virtual_signals(root: Node = $"/root", ignor: Array = []):
	for node in root.get_children():
		if not (node.get_path() in ignor):
			if node.script != null:
				if node.has_method("_process"):
					node.set_process(true)
				if node.has_method("_physics_process"):
					node.set_physics_process(true)
				if node.has_method("_input"):
					node.set_process_input(true)
			connect_virtual_signals(node, ignor)

func scripts_reload(root, ignored):
	for node in root.get_children():
		#var path = node.get_path()
		if node.script:
			print("Скрипт перезагружен: " + node.get_path())
			node.script.reload()
			ready_script_started(node, ignored)

func set_scene(path):
	if path is String:
		print("Установка полученной карты...")
		G.loadSCN = path
		var p = load(path)
		
		p = p.instance()
		p.name = "Node"
		add_child(p, false)
	else:
		print("Распаковка полученной карты...")
		print("Создание дерева нод...")
		G.get_node("Load Screen").event_p(0)
		for i in path:
			var node_spavn = ClassDB.instance(i["node"])
			var no_use = ["node", "script", "path", "tile_data", "filename", "frames", "collision_layer", "collision_mask", "animation"]
			
			node_spavn.name = i["name"]
			
			if i.get("path") != null and get_node_or_null(i["path"]) != null:
				get_node(i["path"]).add_child(node_spavn)
				
				if i.has("tile_data"):
					for f in range(i["tile_data"].size()):
						node_spavn.set_cell(i["tile_data"][f]["position"].x, i["tile_data"][f]["position"].y, i["tile_data"][f]["atlas"], false, false, false, i["tile_data"][f]["position_in_atlas"])
				elif i.has("frames"):
					var SF = SpriteFrames.new()
					printt("ROOT_FRAMES", SF)
					for j in i["frames"].keys():
						SF.add_animation(j)
						SF.set_animation_loop(j, i["frames"][j]["animation_loop"])
						SF.set_animation_speed(j, i["frames"][j]["animation_speed"])
						for d in range(i["frames"][j]["animation_frames"].size()):
							if i["frames"][j]["animation_frames"][d] is String:
								SF.add_frame(j, load(i["frames"][j]["animation_frames"][d]), d)#load(i["frames"][j]["animation_frames"][d]), d)
							else:
								var atla = AtlasTexture.new()
								
								atla.atlas = load(i["frames"][j]["animation_frames"][d]["original_image"])
								atla.region = i["frames"][j]["animation_frames"][d]["region"]
								atla.margin = i["frames"][j]["animation_frames"][d]["margin"]
								atla.filter_clip = i["frames"][j]["animation_frames"][d]["filter_clip"]
								atla.flags = i["frames"][j]["animation_frames"][d]["flags"]
								
								SF.add_frame(j, atla, d)
						
					printt("ROOT_FRAMES", SF.get_animation_names(), SF.get_frame_count(SF.get_animation_names()[0]))
					node_spavn.frames = SF
					printt("ROOT_FRAMES_ANM", node_spavn.animation)
					node_spavn.animation = i["animation"]
				
				setter_param(node_spavn, i, no_use)
				
				if i.has("is_stopped") and i.get("is_stopped") == false:
					node_spavn.start(i["time_left"])
				elif i.has("stream") and i["stream"] != null and i["playing"] == true:
					node_spavn.play(i["playback_position"])
				elif i.has("collision_mask"):
					#if node_spavn is TileMap:
					printt("TILEMAP", i["node"], i["collision_mask"])
					node_spavn.set_collision_mask(i["collision_mask"])
					node_spavn.set_collision_layer(i["collision_layer"])
					if i.has("navigation_layers"):
						node_spavn.set_navigation_layers(i["navigation_layers"])
					#node_spavn.set_collision_mask_bit(0, i["collision_mask"][1])
				
				
				if i.has("script"):
					var script = GDScript.new()
					var parse_res = JSON.parse(i["script"]["code"]).result
					script.source_code = parse_res
					script.reload()
					node_spavn.set_script(script)
				
				if i.has("global_position"):
					node_spavn.set_global_position(i["global_position"])
					node_spavn.rotation = i["rotation"]
				elif i.has("rect_position"):
					node_spavn.rect_position = i["rect_position"]
					node_spavn.rect_size = i["rect_size"]
		
		yield(get_tree(), "idle_frame")
		G.get_node("Load Screen").event_p(20)
		print("Установка переменных...")
		for i in path:
			var node = get_node_or_null(str(i["path"]) + "/" + i["name"])
			if i.has("animations") and node != null:
				
				for anim in i["animations"]:
					var A = Animation.new()
					
					A.set_length(anim["length"])
					A.set_loop(anim["loop"])
					A.set_step(anim["step"])
					
					for track in anim["tracks"]:
						var track_id = A.add_track(track["type"])
						
						A.track_set_enabled(track_id, track["enabled"])
						A.track_set_imported(track_id, track["imported"])
						A.track_set_interpolation_loop_wrap(track_id, track["interpolation_loop"])
						A.track_set_interpolation_type(track_id, track["interpolation"])
						A.track_set_path(track_id, track["path"])
						
						for key in track["keys"]:
							A.track_insert_key(track_id, key["position"], key["value"])
					
					node.add_animation(anim["name"], A)
			if i.has("script") and get_node_or_null(str(i["path"]) + "/" + i["name"]) != null:
				var vars_keys = i["script"]["vars"].keys()
				for k in range(i["script"]["vars"].size()):
					node.set(vars_keys[k], i["script"]["vars"][vars_keys[k]])
		
		yield(get_tree(), "idle_frame")
		G.get_node("Load Screen").event_p(40)
		print("Установка сигналов...")
		for i in path:
			for signal_name in i["signals"].keys():
				var node = get_node_or_null(str(i["path"]) + "/" + i["name"])
				if node != null:
					for signal_data in i["signals"][signal_name]:
						node.connect(signal_name, get_node(signal_data[1]), signal_data[0])
		
		yield(get_tree(), "idle_frame")
		G.get_node("Load Screen").event_p(60)
		print("Запуск виртуальных функций...")
		connect_virtual_signals($"/root/rootGame", ["/root/rootGame/Timer", "/root/rootGame/Timer2"])
		
		G.get_node("Load Screen").event_p(80)
		print("Запуск скриптов...")
		ready_script_started($"/root/rootGame", ["/root/rootGame/Timer", "/root/rootGame/Timer2"])
	yield(get_tree(), "idle_frame")
	G.get_node("Load Screen").event_p(100)
	print("Готово!")
	G.get_node("Load Screen").not_select()

func setter_param(node_spavn, path, no_use):
	for j in path.keys():
		if !j in no_use:
			if path[j] is String and(path[j].begins_with("res://")):
				node_spavn.set(j, load(path[j]))
			elif path[j] is Dictionary and path[j].has("type"):
				if path[j]["type"] == "AtlasTexture":
					var atlas_texture = AtlasTexture.new()
					
					atlas_texture.atlas = load(path[j]["original_image"])
					atlas_texture.region = path[j]["region"]
					atlas_texture.margin = path[j]["margin"]
					atlas_texture.filter_clip = path[j]["filter_clip"]
					atlas_texture.flags = path[j]["flags"]
					
					node_spavn.set(j, atlas_texture)
			elif path[j] is Dictionary and path[j].size() >= 1 and path[j].has("use_setter_param"):
				var param = ClassDB.instance(path[j]["node"])
				node_spavn.set(j, setter_param(param, path[j], no_use))
			elif j != "use_setter_param":
				node_spavn.set(j, path[j])
	return node_spavn

remote func game_win(titre, text, audio:bool = true):
	var v = load("res://Scenes/win_game.res").instance()
	add_child(v)
	get_node("win/ColorRect2/Label").text = titre
	get_node("win/ColorRect2/RichTextLabel").text = text
	if audio:
		get_node("win/AudioStreamPlayer").play()

remote func event_state(path, data = null):
	if get_node_or_null(path) != null and path.begins_with("/root/rootGame/Node") and data != null:
		get_node(path).event_state(data)

remote func create_bullet(gan, bullet, pos, rot = 0, texture = "res://Texture/Other/Items/blebreskinproj.png", damage = 1, attraction = 0, speed = 100, mode:bool = false, output:int = 0, source:Node = null): #Позиция, поворот, текстура, урон, притяжение к земле
	#SD = get_node("/root/rootGame/Node/SettingData")
	var bullet_load = load("res://Scenes/Items/bullet.res").instance()
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
