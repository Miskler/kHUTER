extends Node2D

var map_gen = false
var size_world = Vector2(200, 100)
func _ready():
	Firebase.logEvent("endless_mode", {})
	if get_tree().network_peer == null or get_tree().is_network_server():
		$Timer.start()
		
		if map_gen: return
		map_gen = true
		$TileMap.tiles = $TileMap.unification($TileMap.pruning(size_world.x, size_world.y, $TileMap.generate(size_world.x, size_world.y)), $TileMap.registration($TileMap))
		
		for i in G.start_game_params["ore"]:
			$TileMap.ore($TileMap.tiles, i, 500, 100)
		
		var manual = [
			[
				{"position": {"mode": 1, "value": Vector2(10, 0)}},
				{"tile": {"mode": 0, "shift": Vector2(0, 0), "value": {"tile_name": "ground"}}}, 
				{"tile": {"mode": 0, "shift": Vector2(-3, -3), "value": false}},
				{"tile": {"mode": 0, "shift": Vector2(3, -3), "value": false}},
				{"tile": {"mode": 0, "shift": Vector2(0, -3), "value": false}}
			], 
			[
				{"tile": {"shift": Vector2(-3, -4), "dat": {"tile_name": {"operation": 0, "value": "wall"}, "autotile_coord": {"operation": 0, "value": Vector2(2, 0)}}}},
				{"tile": {"shift": Vector2(-2, -4), "dat": {"tile_name": {"operation": 0, "value": "wall"}, "autotile_coord": {"operation": 0, "value": Vector2(2, 0)}}}},
				{"tile": {"shift": Vector2(-1, -4), "dat": {"tile_name": {"operation": 0, "value": "wall"}, "autotile_coord": {"operation": 0, "value": Vector2(2, 0)}}}},
				
				{"tile": {"shift": Vector2(0, -4), "dat": {"tile_name": {"operation": 0, "value": "wall"}, "autotile_coord": {"operation": 0, "value": Vector2(2, 0)}}}},
				
				{"tile": {"shift": Vector2(1, -4), "dat": {"tile_name": {"operation": 0, "value": "wall"}, "autotile_coord": {"operation": 0, "value": Vector2(2, 0)}}}},
				{"tile": {"shift": Vector2(2, -4), "dat": {"tile_name": {"operation": 0, "value": "wall"}, "autotile_coord": {"operation": 0, "value": Vector2(2, 0)}}}},
				{"tile": {"shift": Vector2(3, -4), "dat": {"tile_name": {"operation": 0, "value": "wall"}, "autotile_coord": {"operation": 0, "value": Vector2(2, 0)}}}},
				
				{"tile": {"shift": Vector2(-3, -3), "dat": {"tile_name": {"operation": 0, "value": "wall"}, "autotile_coord": {"operation": 0, "value": Vector2(2, 0)}}}},
				{"tile": {"shift": Vector2(3, -3), "dat": {"tile_name": {"operation": 0, "value": "wall"}, "autotile_coord": {"operation": 0, "value": Vector2(2, 0)}}}},
				
				
				{"tile": {"shift": Vector2(-3, 0), "dat": {"tile_name": {"operation": 0, "value": "wall"}, "autotile_coord": {"operation": 0, "value": Vector2(2, 0)}}}},
				{"tile": {"shift": Vector2(-2, 0), "dat": {"tile_name": {"operation": 0, "value": "wall"}, "autotile_coord": {"operation": 0, "value": Vector2(2, 0)}}}},
				{"tile": {"shift": Vector2(-1, 0), "dat": {"tile_name": {"operation": 0, "value": "wall"}, "autotile_coord": {"operation": 0, "value": Vector2(2, 0)}}}},
				{"tile": {"shift": Vector2(0, 0), "dat": {"tile_name": {"operation": 0, "value": "wall"}, "autotile_coord": {"operation": 0, "value": Vector2(2, 0)}}}},
				{"tile": {"shift": Vector2(1, 0), "dat": {"tile_name": {"operation": 0, "value": "wall"}, "autotile_coord": {"operation": 0, "value": Vector2(2, 0)}}}},
				{"tile": {"shift": Vector2(2, 0), "dat": {"tile_name": {"operation": 0, "value": "wall"}, "autotile_coord": {"operation": 0, "value": Vector2(2, 0)}}}},
				{"tile": {"shift": Vector2(3, 0), "dat": {"tile_name": {"operation": 0, "value": "wall"}, "autotile_coord": {"operation": 0, "value": Vector2(2, 0)}}}},
				
				{"tile": {"shift": Vector2(0, -1), "dat": {"tile_name": {"operation": 0, "value": "chest"}, "autotile_coord": {"operation": 0, "value": Vector2(2, 0)}, "instruction": {"operation": 0, "value": [[{}, {"item": "bread"}, {}, {}]]}}}},
				
				{"tile_clear": {"shift": Vector2(-3, -1)}},
				{"tile_clear": {"shift": Vector2(-2, -1)}},
				{"tile_clear": {"shift": Vector2(-1, -1)}},
				{"tile_clear": {"shift": Vector2(1, -1)}},
				{"tile_clear": {"shift": Vector2(2, -1)}},
				{"tile_clear": {"shift": Vector2(3, -1)}},
				
				{"tile_clear": {"shift": Vector2(-3, -2)}},
				{"tile_clear": {"shift": Vector2(-2, -2)}},
				{"tile_clear": {"shift": Vector2(-1, -2)}},
				{"tile_clear": {"shift": Vector2(0, -2)}},
				{"tile_clear": {"shift": Vector2(1, -2)}},
				{"tile_clear": {"shift": Vector2(2, -2)}},
				{"tile_clear": {"shift": Vector2(3, -2)}},
				
				{"tile_clear": {"shift": Vector2(-2, -3)}},
				{"tile_clear": {"shift": Vector2(-1, -3)}},
				{"tile_clear": {"shift": Vector2(0, -3)}},
				{"tile_clear": {"shift": Vector2(1, -3)}},
				{"tile_clear": {"shift": Vector2(2, -3)}},
			]
		]
		$TileMap.tiles = $TileMap.structure($TileMap.tiles, manual, 1)
		if get_tree().network_peer != null:
			$TileMap.rpc("structure", $TileMap.tiles, manual, 1)
		
		manual = [
			[
				{"position": {"mode": 1, "value": Vector2(10, 0)}},
				{"tile": {"mode": 0, "shift": Vector2(0, 0), "value": {"tile_name": "ground"}}}, 
				{"tile": {"mode": 0, "shift": Vector2(0, -1), "value": false}},
				{"tile": {"mode": 0, "shift": Vector2(-1, -1), "value": false}},
				{"tile": {"mode": 0, "shift": Vector2(1, -1), "value": false}}
			], 
			[
				{"object": {"path": "res://scenes/entities/basic/slime.tscn", "pos": Vector2(32, 0)}}#"pos": Vector2(32, -64), 
			]
		]
		$TileMap.structure($TileMap.tiles, manual, 40, 60)
		if get_tree().network_peer != null:
			$TileMap.rpc("structure", $TileMap.tiles, manual, 40, 60)
		
		
		manual = [
			[
				{"position": {"mode": 1, "value": Vector2(10, 0)}},
				{"tile": {"mode": 0, "shift": Vector2(-2, 0), "value": true}},
				{"tile": {"mode": 0, "shift": Vector2(-1, 0), "value": true}},
				{"tile": {"mode": 0, "shift": Vector2(0, 0), "value": true}},
				{"tile": {"mode": 0, "shift": Vector2(1, 0), "value": true}},
				{"tile": {"mode": 0, "shift": Vector2(2, 0), "value": true}},
				
				{"tile": {"mode": 0, "shift": Vector2(0, -1), "value": false}},
				{"tile": {"mode": 0, "shift": Vector2(-1, -1), "value": false}},
				{"tile": {"mode": 0, "shift": Vector2(1, -1), "value": false}}
			], 
			[
				{"object": {"path": "res://scenes/entities/basic/phase_firefly.tscn"}}#"pos": Vector2(32, -64), 
			]
		]
		$TileMap.structure($TileMap.tiles, manual, 120, 40)
		if get_tree().network_peer != null:
			$TileMap.rpc("structure", $TileMap.tiles, manual, 120, 40)
		
		$TileMap.render()
		
		
		manual = [
			[
				{"position": {"mode": 1, "value": Vector2(20, 20)}},
				{"tile": {"mode": 0, "shift": Vector2(-2, 0), "value": true}},
				{"tile": {"mode": 0, "shift": Vector2(-1, 0), "value": true}},
				{"tile": {"mode": 0, "shift": Vector2(0, 0), "value": true}},
				{"tile": {"mode": 0, "shift": Vector2(1, 0), "value": true}},
				{"tile": {"mode": 0, "shift": Vector2(2, 0), "value": true}},
				{"tile": {"mode": 0, "shift": Vector2(2, 2), "value": true}},
				{"tile": {"mode": 0, "shift": Vector2(2, -2), "value": false}},
				
				{"tile": {"mode": 0, "shift": Vector2(0, -1), "value": false}},
				{"tile": {"mode": 0, "shift": Vector2(-1, -1), "value": false}},
				{"tile": {"mode": 0, "shift": Vector2(1, -1), "value": false}}
			], 
			[
				{"tile": {"shift": Vector2(0, 0), "dat": {"tile_name": {"operation": 0, "value": "craft"}, "autotile_coord": {"operation": 0, "value": Vector2(2, 0)}}}},
				{"tile": {"shift": Vector2(1, 0), "dat": {"tile_name": {"operation": 0, "value": "chest"}, "autotile_coord": {"operation": 0, "value": Vector2(2, 0)}}}},
				
				{"tile_clear": {"shift": Vector2(0, -1)}},
				{"tile_clear": {"shift": Vector2(1, -1)}},
				{"tile_clear": {"shift": Vector2(0, -2)}},
				{"tile_clear": {"shift": Vector2(1, -2)}},
				
				{"object": {"pos": Vector2(64, -32), "path": "res://scenes/entities/controlled/player.tscn"}}# 
			]
		]
		$TileMap.structure($TileMap.tiles, manual, 1, 10)
		G.live_player_roster[G.my_id()] = G.game_settings["player_name"]
		
		$SettingData.map_settings["creation_position"] = get_node("Player").global_position
# warning-ignore:return_value_discarded
		get_node("Player").connect("died", self, "died")
		if get_tree().network_peer != null:
			rpc("map_sing", $TileMap.tiles, $SettingData.map_settings["creation_position"])
remote func map_sing(mapp, spavn_pos):
	$TileMap.tiles = mapp
	$SettingData.map_settings["creation_position"] = spavn_pos
	get_node("/root/rootGame").revive_player(G.my_id())

remote func died(cause, remote_signal:bool = false):
	if get_tree().network_peer != null and not remote_signal:
		rpc("died", cause, true)
	elif remote_signal:
		if get_node_or_null("Player") and get_node("Player").has_method("show_died"):
			get_node("Player").show_died("Напарник\nуничтожен")
	
	$Guider/CanvasLayer/Control2.hide()
	$Guider/CanvasLayer/Control3.show()
	
	var file = File.new()
	if not file.file_exists("user://SaveGame/endless_data.json"):
		file.open("user://SaveGame/endless_data.json", File.WRITE)
		file.store_line(to_json([0, 0, 0]))
		file.close()
	file.open("user://SaveGame/endless_data.json", File.READ)
	var data = parse_json(file.get_as_text())
	
	$Guider/CanvasLayer/Control3/Label2.text = "Прожито волн: "+str(id)+"\nОчков: "+str($Guider/Node/Events.coin)+"\nРазрушено дройдов: "+str($Guider/Node/Events.dead_droids)+"\n\nРекорд волн: "+str(data[0])+"\nРекорд очков: "+str(data[1])+"\nРекорд разрушения дройдов: "+str(data[2])
	
	if data[1] < $Guider/Node/Events.coin:
		file.open("user://SaveGame/endless_data.json", File.WRITE)
		file.store_line(to_json([id, $Guider/Node/Events.coin, $Guider/Node/Events.dead_droids]))
		file.close()
	
	get_node("Player/Camera2D/interface/died").modulate.a = 0
	get_node("Player").modulate.a = 0


func _process(_delta):
	if get_node_or_null("Player"):
		if get_node("Player").global_position.y > 7500:
			if get_node("Player").has_method("show_died"):
				get_node("Player").show_died("Поглощён\nоболочкой")
			else:
				get_node("Player").global_position.y = 7400

var id = 0
func wave(count:int = 10):
	if get_tree().network_peer != null and not get_tree().is_network_server():
		return
	
	count = clamp(count-id/2, 2, 10)
	var manual = [
		[
			{"position": {"mode": 1, "value": Vector2(10, 0)}},
			{"tile": {"mode": 0, "shift": Vector2(0, 0), "value": {"tile_name": "ground"}}}, 
			{"tile": {"mode": 0, "shift": Vector2(0, -1), "value": false}},
			{"tile": {"mode": 0, "shift": Vector2(-1, -1), "value": false}},
			{"tile": {"mode": 0, "shift": Vector2(1, -1), "value": false}}
		], 
		[
			{"object": {"path": "res://scenes/entities/basic/slime.tscn", "pos": Vector2(32, 0)}}#"pos": Vector2(32, -64), 
		]
	]
	$TileMap.structure($TileMap.tiles, manual, count, 120)
	if get_tree().network_peer != null:
		$TileMap.rpc("structure", $TileMap.tiles, manual, count, 120)
	
	
	manual = [
		[
			{"position": {"mode": 1, "value": Vector2(10, 0)}},
			{"tile": {"mode": 0, "shift": Vector2(-2, 0), "value": true}},
			{"tile": {"mode": 0, "shift": Vector2(-1, 0), "value": true}},
			{"tile": {"mode": 0, "shift": Vector2(0, 0), "value": true}},
			{"tile": {"mode": 0, "shift": Vector2(1, 0), "value": true}},
			{"tile": {"mode": 0, "shift": Vector2(2, 0), "value": true}},
			
			{"tile": {"mode": 0, "shift": Vector2(0, -1), "value": false}},
			{"tile": {"mode": 0, "shift": Vector2(-1, -1), "value": false}},
			{"tile": {"mode": 0, "shift": Vector2(1, -1), "value": false}}
		], 
		[
			{"object": {"path": "res://scenes/entities/basic/phase_firefly.tscn"}}#"pos": Vector2(32, -64), 
		]
	]
	$TileMap.structure($TileMap.tiles, manual, count, 80)
	if get_tree().network_peer != null:
		$TileMap.rpc("structure", $TileMap.tiles, manual, count, 80)
	
	
	manual = [
		[
			{"position": {"mode": 1, "value": Vector2(10, 10)}},
			{"tile": {"mode": 0, "shift": Vector2(0, 0), "value": {"tile_name": "ground"}}},
			{"tile": {"mode": 0, "shift": Vector2(-1, 0), "value": {"tile_name": "ground"}}},
			
			{"tile": {"mode": 0, "shift": Vector2(0, -1), "value": false}},
			{"tile": {"mode": 0, "shift": Vector2(-1, -1), "value": false}},
			{"tile": {"mode": 0, "shift": Vector2(0, -2), "value": false}},
			{"tile": {"mode": 0, "shift": Vector2(-1, -2), "value": false}}
		], 
		[
			{"object": {"path": "res://scenes/entities/basic/droid.tscn", "pos": Vector2(32, 0)}}#"pos": Vector2(32, -64), 
		]
	]
	$TileMap.structure($TileMap.tiles, manual, 20, 70)
	if get_tree().network_peer != null:
		$TileMap.rpc("structure", $TileMap.tiles, manual, 20, 70)
	
	id += 1


func restart(rem:bool = false):
	if not rem and get_tree().network_peer != null:
		restart(true)
	
	map_gen = false
	id = 0
	#$Guider/Node/Events.start = false
	$Guider/Node/Events.trek_play = false
	$Guider/Node/Events.coin = 0.0
	$Guider/Node/Events.wave = 0.0
	$Guider/Node/Events.time = 60.0
	$Guider/Node/Events.dead_droids = 0
	$Guider/CanvasLayer/Control2.show()
	$Guider/CanvasLayer/Control2/Control.modulate.a = 0.0
	$Guider/CanvasLayer/Control2/Control2.modulate.a = 0.0
	$Guider/CanvasLayer/Control2/Control3.modulate.a = 0.0
	$SignalCenter.npcs = {}
	
	
	for i in get_children():
		if not i.name in ["SignalCenter", "Cloud", "M", "TileMap", "SettingData", "Timer", "Guider"]:
			i.queue_free()
	$M.clear()
	$TileMap.tiles = {}
	$TileMap.clear()
	
	$Guider/CanvasLayer/Control3.hide()
	
	$M._ready()
	yield(get_tree().create_timer(0.1),"timeout")
	_ready()


func spect():
	$Guider/CanvasLayer/Control3.hide()
	get_node("Player/Camera2D/interface/died").ok_specter()
