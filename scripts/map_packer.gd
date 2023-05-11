extends Node

signal save_done
func save_game(ignor:Array = ["/root/rootGame/Timer", "/root/rootGame/Timer2"]):
	if get_node_or_null("/root/rootGame/Node") != null:
		var list_nodes = get_nodes($"/root/rootGame", ignor)
		var nodes = list_param(list_nodes)
		
		var array_to_save = [G.game_settings["version"], G.game_settings["player_name"], OS.get_datetime()]
		
		emit_signal("save_done")
		return [nodes, array_to_save]

func get_params(node:Object, node_list = {}):
	if node is Object and is_instance_valid(node):
		for h in node.get_property_list():
			var no_add = ["custom_multiplayer", "multiplayer", "Node", "script", "tile_set", "frames", "collision_mask", "collision_layer"]
			if node.get_script():
				for j in node.get_script().get_script_property_list():
					no_add.append(j["name"])
			if !h["name"] in no_add:
				var node_property = node.get(h["name"])
				if !node_property is Object:
					node_list[h["name"]] = node_property
				elif node_property is Object and !is_instance_valid(node_property):
					node_list[h["name"]] = null
				elif node_property is AtlasTexture:
					node_list[h["name"]] = {"type": "AtlasTexture"}
					
					node_list[h["name"]]["original_image"] = node_property.atlas.get_path()
					node_list[h["name"]]["region"] = node_property.region
					node_list[h["name"]]["margin"] = node_property.margin
					node_list[h["name"]]["filter_clip"] = node_property.filter_clip
					node_list[h["name"]]["flags"] = node_property.flags
				else:
					var end = str(node_property.get_path())
					if end.ends_with(".png") or end.ends_with(".jpg") or end.ends_with(".otf") or end.ends_with(".mp3"):
						node_list[h["name"]] = node_property.get_path()
					else:
						var set_node = get_params(node_property)
						node_list[h["name"]] = set_node
						node_list[h["name"]]["use_setter_param"] = true
			node_list["node"] = node.get_class()
	else: node_list = null
	
	return node_list

func list_param(nodes_list = []):
	for i in range(nodes_list.size()):
		var node = get_node(nodes_list[i]["path"])
		
		nodes_list[i] = get_params(node, nodes_list[i])
		nodes_list[i]["path"] = node.get_parent().get_path() #Родитель ноды (нужен расшифровщику, чтобы знал кому добавить ноду)
		
		if node is TileMap and node.tile_set != null:
			nodes_list[i]["tile_set"] = node.tile_set.get_path()
			#nodes_list[i]["tile_set"] = {}
			#for id in node.tile_set.get_tiles_ids():
			#	var tile_dat = {}
			#	
			#	tile_dat["tile_mode"] = node.tile_set.tile_get_tile_mode(id) #ТИП ТАЙЛА
			#	
			#	tile_dat["texture"] = node.tile_set.tile_get_texture(id) #ТЕКСТУРА
			#	if tile_dat["texture"] != null: tile_dat["texture"] = tile_dat["texture"].resource_path
			#	
			#	tile_dat["normal_map"] = node.tile_set.tile_get_normal_map(id) #НОРМАЛ МАП
			#	if tile_dat["normal_map"] != null: tile_dat["normal_map"] = tile_dat["normal_map"].resource_path
			#	
			#	tile_dat["material"] = get_params(node.tile_set.tile_get_material(id)) #МАТЕРИАЛ
			#	tile_dat["name"] = node.tile_set.tile_get_name(id) #ИМЯ
			#	
			#	if tile_dat["tile_mode"] == 0: #ТАЙЛ:
			#		tile_dat["region"] = node.tile_set.tile_get_region(id) #РЕГИОН
			#		
			#		tile_dat["shapes"] = node.tile_set.tile_get_shapes(id) #ШЕЙП
			#		for h in range(tile_dat["shapes"].size()):
			#			tile_dat["shapes"][h]["shape"] = get_params(tile_dat["shapes"][h]["shape"])
			#		
			#		tile_dat["light_occluder"] = get_params(node.tile_set.tile_get_light_occluder(id)) #СВЕТ ШЕЙП
			#		tile_dat["navigation_polygon"] = get_params(node.tile_set.tile_get_navigation_polygon(id)) #НАВИГАЦИЯ ШЕЙП
			#		tile_dat["z_index"] = node.tile_set.tile_get_z_index(id) #Z-ИНДЕКС
			#	else: #ДРУГОЕ:
			#		
			#		tile_dat["icon"] = node.tile_set.autotile_get_icon_coordinate(id) #ИКОНКА
			#		tile_dat["spacing"] = node.tile_set.autotile_get_spacing(id) #Пробел между тайлами
			#		
			#		
			#		tile_dat["sub_tiles"] = {}
			#		
			#		for x in range(node.tile_set.tile_get_texture(id).get_size().x / node.cell_size.x): #ПОДТАЙЛЫ:
			#			tile_dat["sub_tiles"][x] = {}
			#			for y in range(node.tile_set.tile_get_texture(id).get_size().y / node.cell_size.y): #ПОДТАЙЛЫ:
			#				tile_dat["sub_tiles"][x][y] = {}
			#				
			#				tile_dat["sub_tiles"][x][y]["z_index"] = node.tile_set.autotile_get_z_index(id, Vector2(x, y)) #Z-ИНДЕКС
			#				tile_dat["sub_tiles"][x][y]["priority"] = node.tile_set.autotile_get_subtile_priority(id, Vector2(x, y)) #ПРИОРИТЕТ
			#				
			#				tile_dat["sub_tiles"][x][y]["shapes"] = node.tile_set.tile_get_shapes(id) #РАБОТАЕТ ЧЕРЕЗ ЖОПУ #ШЕЙП
			#				for h in range(tile_dat["sub_tiles"][x][y]["shapes"].size()):
			#					tile_dat["sub_tiles"][x][y]["shapes"][h]["shape"] = get_params(tile_dat["sub_tiles"][x][y]["shapes"][h]["shape"])
			#				
			#				tile_dat["sub_tiles"][x][y]["light_occluder"] = get_params(node.tile_set.autotile_get_light_occluder(id, Vector2(x, y))) #СВЕТ ШЕЙП
			#				tile_dat["sub_tiles"][x][y]["navigation_polygon"] = get_params(node.tile_set.autotile_get_navigation_polygon(id, Vector2(x, y))) #НАВИГАЦИЯ ШЕЙП
			#				
			#				if tile_dat["tile_mode"] == 1: #АВТОТИЛЬ:
			#					tile_dat["sub_tiles"][x][y]["bitmask"] = node.tile_set.autotile_get_bitmask(id, Vector2(x, y)) #БИТОВАЯ МАСКА
			#	
			#	nodes_list[i]["tile_set"][id] = tile_dat
			
			nodes_list[i]["tile_data"] = []
			for b in node.get_used_cells():
				var j = {"position": b, "atlas": node.get_cellv(b), "position_in_atlas": node.get_cell_autotile_coord(b.x, b.y)}
				nodes_list[i]["tile_data"].append(j)
		
		if node is KinematicBody2D or node is RigidBody2D or node is StaticBody2D or node is TileMap:
			nodes_list[i]["collision_mask"] = node.get_collision_mask()
			nodes_list[i]["collision_layer"] = node.get_collision_layer()
			if node is TileMap:
				nodes_list[i]["navigation_layers"] = node.get_navigation_layers()
		elif node is Timer:
			nodes_list[i]["is_stopped"] = node.is_stopped()
			nodes_list[i]["time_left"] = node.time_left
		elif node is AudioStreamPlayer or node is AudioStreamPlayer2D:
			nodes_list[i]["playback_position"] = node.get_playback_position()
		elif node is AnimatedSprite and node.get_sprite_frames() != null:
			var frames_object = node.get_sprite_frames()
			nodes_list[i]["frames"] = {}
			for j in frames_object.get_animation_names():
				nodes_list[i]["frames"][j] = {
					"animation_loop": frames_object.get_animation_loop(j),
					"animation_speed": frames_object.get_animation_speed(j),
					"animation_frames": []
				}
				for k in range(frames_object.get_frame_count(j)):
					var par = frames_object.get_frame(j, k)
					if par is AtlasTexture:
						var f = {}
						
						f["type"] = "AtlasTexture"
						f["original_image"] = par.atlas.get_path()
						f["region"] = par.region
						f["margin"] = par.margin
						f["filter_clip"] = par.filter_clip
						f["flags"] = par.flags
						
						par = f
					else: par = par.get_path()
					
					nodes_list[i]["frames"][j]["animation_frames"].append(par)
		elif node is AnimationPlayer and node.get_animation_list().size() > 0:
			nodes_list[i]["animations"] = []
			for j in range(node.get_animation_list().size()):
				nodes_list[i]["animations"].append({})
				var anim = node.get_animation(node.get_animation_list()[j])
				nodes_list[i]["animations"][j]["name"] = node.get_animation_list()[j]
				nodes_list[i]["animations"][j]["length"] = anim.get_length()
				nodes_list[i]["animations"][j]["loop"] = anim.has_loop()
				nodes_list[i]["animations"][j]["step"] = anim.get_step()
				nodes_list[i]["animations"][j]["tracks"] = []
				for k in anim.get_track_count():
					nodes_list[i]["animations"][j]["tracks"].append({})
					nodes_list[i]["animations"][j]["tracks"][k]["interpolation"] = anim.track_get_interpolation_type(k)
					nodes_list[i]["animations"][j]["tracks"][k]["type"] = anim.track_get_type(k)
					nodes_list[i]["animations"][j]["tracks"][k]["enabled"] = anim.track_is_enabled(k)
					nodes_list[i]["animations"][j]["tracks"][k]["imported"] = anim.track_is_imported(k)
					nodes_list[i]["animations"][j]["tracks"][k]["interpolation_loop"] = anim.track_get_interpolation_loop_wrap(k)
					nodes_list[i]["animations"][j]["tracks"][k]["path"] = anim.track_get_path(k)
					
					nodes_list[i]["animations"][j]["tracks"][k]["keys"] = []
					for f in anim.track_get_key_count(k):
						nodes_list[i]["animations"][j]["tracks"][k]["keys"].append({})
						nodes_list[i]["animations"][j]["tracks"][k]["keys"][f]["position"] = anim.track_get_key_time(k, f)
						nodes_list[i]["animations"][j]["tracks"][k]["keys"][f]["value"] = anim.track_get_key_value(k, f)
		
		if is_instance_valid(node.get_script()):
			nodes_list[i]["script"] = {}
			nodes_list[i]["script"]["code"] = to_json(node.get_script().source_code)
			nodes_list[i]["script"]["vars"] = {}
			
			var node_vars = node.get_script().get_script_property_list()
			for g in node_vars:
				if !(node.get(g["name"]) is Object):
					nodes_list[i]["script"]["vars"][g["name"]] = node.get(g["name"])
				elif is_instance_valid(node.get(g["name"])):
					nodes_list[i]["script"]["vars"][g["name"]] = node.get(g["name"]).get_path()
		
		nodes_list[i]["signals"] = {}
		for d in node.get_signal_list():
			var dats = node.get_signal_connection_list(d["name"])
			
			nodes_list[i]["signals"][d["name"]] = []
			
			if dats.size() > 0:
				for r in dats:
					nodes_list[i]["signals"][d["name"]].append([r["method"], r["target"].get_path()])
	return nodes_list

remote func send_map(user_id, user_name):
	if !G.player_roster.has(user_id):
		G.player_roster[user_id] = user_name
		G.live_player_roster[user_id] = user_name
	yield(get_tree(), "idle_frame")
	print("Передача запущенной карты по запросу \""+str(user_name)+"\" ("+str(user_id)+")")
	
	var ignor = ["/root/rootGame/Node/Player", "/root/rootGame/Timer", "/root/rootGame/Timer2"]
	
	for i in get_parent().live_player_roster.keys():
		ignor.append("/root/rootGame/Node/" + str(i))
	
	make_nodes($"/root/rootGame", ignor, user_id)

func get_nodes(root: Node, ignored = [], list = []):
	for node in root.get_children():
		var path = node.get_path()
		if !path in ignored and not str(node.name).begins_with("@@"):
			if "@" in node.name:
				node.name = node.name.replace("@", "") #Ремонтируем имя
				path = node.get_path()
			
			list.append({"path": path})
			get_nodes(node, ignored, list)
	return list

func make_nodes(root, ignored, id_user:int = 0):
	var list_nodes = get_nodes(root, ignored)
	var nodes = list_param(list_nodes)
	send(nodes, id_user)

func send(nodes, id_user:int = 0):
	print("Передача карты размером - " + str(nodes.size()))
	get_node("/root/rootGame").rpc_id(id_user, "file_select", nodes, get_parent().player_roster, get_parent().live_player_roster)
