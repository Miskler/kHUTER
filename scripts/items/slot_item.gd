extends Control

#Предмет не объединится если важные данные не совпадают
#Проверяются только ключи имеющиеся у данного предмета и добавляймого
#Новые ключи будут добавлены
@export var significant_data = {}
#Предмет не проверяет данный массив на совпадение 
#Новые ключи будут добавлены
#Если префикс re_ то данные будут заменины добовляймым предметом
#Если префикс not_ данные будут не тронуты
#Если префикс uni_ данные будут объединены, если это невозможно то будет
#Действовать как not_
#Если префикса нет, то будет действовать как not_
@export var insignificant_data = {}

#Устанавливается в случае отцуцтвия нормальных данных
#Созданный через эту переменную предмет невозможно взять
#Но он так же работает с логикой
@export var default_significant_data = {}
@export var default_insignificant_data = {}

@onready var SD = get_node_or_null("/root/rootGame/Node/SettingData")

#False - запрещает, True - разрешает
@export var settings_slot = {
	"multiplayer_synchronization": false,
	"permission_to_use": true,
	"hide_scope": false,
	"hide_background": true,
	"hide_health": false,
	"hide_quantity": false,
	"slot_off": false,
	"take_items": true,
	"put_items": true,
	"texture_flip_h": false,
	"texture_flip_v": false,
	"valid_types": [], #В слот можно поместить только предметы тип которых есть в этом массиве, если пуст то ограничений нет
	"slot_capacity": -1, #Предел предметов в слоте, даже если стак предмета выше, больше этого значения положить нельзя, если -1 нет ограничений
}


#Сигналы

#Курсор навёдён на предмет
signal use_item(slot, significant, insignificant) #Нажата СКМ

#При условии что операция взятия или добавления может быть выполнена
#Если mode - True в слот положили, если False из него взяли, Null - и взяли и положили
signal LMB_item(slot, significant, insignificant, hand_significant, hand_insignificant, mode) #Нажата ЛКМ
signal RMB_item(slot, significant, insignificant, hand_significant, hand_insignificant, mode) #Нажата ПКМ

#Реагирует так же и на ЛКМ и ПКМ (СКМ игнорит)
signal pressed_item(slot, significant, insignificant, button) #Реагирует на любую клавишу кроме СКМ

#Срабатывает когда предмет был принудительно установлен
#Срабатывает только когда был установлен по приказу скрипта, а не игрока
signal installed_item(slot, significant, insignificant)


#Дополнительные сигналы

#Вызывается системой крафта когда предмет не может быть удалён (рецепт запретил)
signal item_not_deleted(slot, recipes)


#Функции вызова
func _ready():
	SD = get_node_or_null("/root/rootGame/Node/SettingData")
	
	$Scales/Health.set("theme_override_styles/fg", $Scales/Health.get("theme_override_styles/fg").duplicate())
	$Scales/Health.visible = not settings_slot["hide_health"]
	$Scales/Quantity.visible = not settings_slot["hide_quantity"]
	$Scope.visible = not settings_slot["hide_scope"]
	$Background.visible = not settings_slot["hide_background"]
	
	$Texture2D.flip_h = settings_slot["texture_flip_h"]
	$Texture2D.flip_v = settings_slot["texture_flip_v"]
	
	settings_slot = settings_slot.duplicate(true)
	
	var def = data_repair(default_significant_data, default_insignificant_data)
	default_significant_data = def[0].duplicate()
	default_insignificant_data = def[1].duplicate()
	
	var sta = data_repair(significant_data, insignificant_data)
	significant_data = sta[0].duplicate()
	insignificant_data = sta[1].duplicate()
	
	if not significant_data.has("item"):
		significant_data = default_significant_data.duplicate()
		insignificant_data = default_insignificant_data.duplicate()
	
	$AnimEvent.start()
# warning-ignore:return_value_discarded
	$AnimEvent.connect("timeout", Callable(self, "anim_event"))
	
	installation_item()
	item_connecting()

@onready var hand_node = get_node_or_null("/root/rootGame/Node/Player/Camera2D/interface/MoveItem")
func _input(event):
	SD = get_node_or_null("/root/rootGame/Node/SettingData")
	hand_node = get_node_or_null("/root/rootGame/Node/Player/Camera2D/interface/MoveItem")
	if not G.game_settings["mobile"] and hand_node != null:
		if !event is InputEventMouseMotion and !event is InputEventScreenDrag and event.pressed and get_global_rect().has_point(get_global_mouse_position()) and settings_slot["slot_off"] == false:
			#event.pressed and 
			if Input.is_action_just_pressed("Use") and settings_slot["permission_to_use"] == true:
				emit_signal("use_item", self, significant_data, insignificant_data)
			elif event.get("button_index") != 3:
				emit_signal("pressed_item", self, significant_data, insignificant_data, event)
			
			if (event.get("button_index") and event.button_index in [1, 2]):
				
				if hand_node.get_node("HandSlot").significant_data.hash() == hand_node.get_node("HandSlot").default_significant_data.hash() and significant_data.hash() != default_significant_data.hash():
					#Берём в руку половину или всё
					if not settings_slot["take_items"]:
						return
					
					
					var mode = false
					if event.button_index == 1:
						mode = true
					
					var get_data = get_item(mode)
					
					hand_node.significant_data = get_data[0]
					hand_node.insignificant_data = get_data[1]
					
					item_connecting()
					if event.button_index == 1:
						emit_signal("LMB_item", self, significant_data, insignificant_data, hand_node.significant_data, hand_node.insignificant_data, false)
					else:
						emit_signal("RMB_item", self, significant_data, insignificant_data, hand_node.significant_data, hand_node.insignificant_data, false)
				elif significant_data.hash() == default_significant_data.hash() and(settings_slot["valid_types"].size() <= 0 or str(hand_node.significant_data.get("type")) in settings_slot["valid_types"]):
					#Кладём в слот если возможно
					#Половину или полностью
					
					if not settings_slot["put_items"]:
						return
					
					
					var number = [hand_node.insignificant_data.duplicate(), hand_node.significant_data.duplicate(), hand_node.insignificant_data.duplicate()]
					
					if number[1].size() <= 0: return
					
					if event.button_index == 2:
						number[0]["uni_quantity"] = 1
					
					var add_data = add_item(hand_node.significant_data, number[0])
					
					if add_data[0] == false:
						add_data = [null] + get_item(true)
						add_data[1] = number[1]
						add_data[2] = number[2]
					elif event.button_index == 2 and number[2]["uni_quantity"] > 1:
						add_data[1] = number[1]
						number[2]["uni_quantity"] -= 1
						add_data[2] = number[2]
					
					#if add_data[0] == true:
					hand_node.significant_data = add_data[1]
					hand_node.insignificant_data = add_data[2]
					#elif add_data[0] == null:
					#	hand_node.significant_data = {}
					#	hand_node.insignificant_data = {}
					
					item_connecting()
					if event.button_index == 1:
						emit_signal("LMB_item", self, significant_data, insignificant_data, hand_node.significant_data, hand_node.insignificant_data, true)
					else:
						emit_signal("RMB_item", self, significant_data, insignificant_data, hand_node.significant_data, hand_node.insignificant_data, true)
				else:
					#Если предметы совпадают - объеденяем
					#Если не совпадают - меняем местами
					if not settings_slot["put_items"] or not settings_slot["take_items"]:
						return
					
					var dop = hand_node.insignificant_data.duplicate()
					if event.button_index == 2:
						dop["uni_quantity"] = 1
					var add_data = add_item(hand_node.significant_data, dop)
					
					if add_data[0] == false: #Меняем местами
						if settings_slot["valid_types"].size() <= 0 or str(hand_node.significant_data.get("type")) in settings_slot["valid_types"]:
							var dopi = [significant_data.duplicate(), insignificant_data.duplicate()]
							var get_data = get_item(true)
							
							set_item(add_data[1].duplicate(), hand_node.insignificant_data.duplicate())
							
							if dopi[0].hash() == default_significant_data.hash() and dopi[1].hash() == default_insignificant_data.hash():
								hand_node.significant_data = hand_node.get_node("HandSlot").default_significant_data.duplicate(true)
								hand_node.insignificant_data = hand_node.get_node("HandSlot").default_insignificant_data.duplicate(true)
							else:
								hand_node.significant_data = get_data[0]
								hand_node.insignificant_data = get_data[1]
							
							item_connecting()
							if event.button_index == 1:
								emit_signal("LMB_item", self, significant_data, insignificant_data, hand_node.significant_data, hand_node.insignificant_data, null)
							else:
								emit_signal("RMB_item", self, significant_data, insignificant_data, hand_node.significant_data, hand_node.insignificant_data, null)
					else: #Объединяем
						if event.button_index == 1:
							hand_node.significant_data = add_data[1]
							hand_node.insignificant_data = add_data[2]
						else:
							hand_node.insignificant_data["uni_quantity"] -= 1
							if int(hand_node.insignificant_data["uni_quantity"]) <= 0:
								hand_node.significant_data = hand_node.get_node("HandSlot").default_significant_data.duplicate(true)
								hand_node.insignificant_data = hand_node.get_node("HandSlot").default_insignificant_data.duplicate(true)
						
						item_connecting()
						if event.button_index == 1:
							emit_signal("LMB_item", self, significant_data, insignificant_data, hand_node.significant_data, hand_node.insignificant_data, true)
						else:
							emit_signal("RMB_item", self, significant_data, insignificant_data, hand_node.significant_data, hand_node.insignificant_data, true)
				
				hand_node.data_updated()
				installation_item()
func press(time, count):
	if G.game_settings["mobile"]:
		if time >= 1 and significant_data.hash() != default_significant_data.hash(): #Используем
			if settings_slot["permission_to_use"] == true:
				emit_signal("use_item", self, significant_data, insignificant_data)
		else: #Перебераем предметы
			if hand_node.get_node("HandSlot").significant_data.hash() == hand_node.get_node("HandSlot").default_significant_data.hash() and significant_data.hash() != default_significant_data.hash():
				#Берём в руку половину или всё
				
				if not settings_slot["take_items"]:
					return
				
				var mode = false
				if count == 1:
					mode = true
				
				var get_data = get_item(mode)
				
				hand_node.significant_data = get_data[0]
				hand_node.insignificant_data = get_data[1]
				
				item_connecting()
				if count == 1:
					emit_signal("LMB_item", self, significant_data, insignificant_data, hand_node.significant_data, hand_node.insignificant_data, false)
				else:
					emit_signal("RMB_item", self, significant_data, insignificant_data, hand_node.significant_data, hand_node.insignificant_data, false)
			elif significant_data.hash() == default_significant_data.hash() and(settings_slot["valid_types"].size() <= 0 or str(hand_node.significant_data.get("type")) in settings_slot["valid_types"]):
				#Кладём в слот если возможно
				#Половину или полностью
				
				if not settings_slot["put_items"]:
					return
				
				
				var number = [hand_node.insignificant_data.duplicate(), hand_node.significant_data.duplicate(), hand_node.insignificant_data.duplicate()]
				
				if number[1].size() <= 0: return
				
				var coun = number[0]["uni_quantity"]
				if time >= 1:
					coun = int(round(float(coun)/2))
				number[0]["uni_quantity"] = coun
				
				var add_data = add_item(hand_node.significant_data, number[0])
				
				if add_data[0] == false:
					get_item(true)
				elif number[2]["uni_quantity"] > 1:
					add_data[1] = number[1]
					
					number[2]["uni_quantity"] -= coun
					if add_data[2].has("uni_quantity"):
						number[2]["uni_quantity"] -= add_data[2]["uni_quantity"]
					
					add_data[2] = number[2]
				
				if add_data[0] == true and number[2]["uni_quantity"] > 0:
					hand_node.significant_data = add_data[1]
					hand_node.insignificant_data = add_data[2]
				elif add_data[0] == null or number[2]["uni_quantity"] <= 0:
					hand_node.significant_data = {}
					hand_node.insignificant_data = {}
				
				item_connecting()
				if time < 1:
					emit_signal("LMB_item", self, significant_data, insignificant_data, hand_node.significant_data, hand_node.insignificant_data, true)
				else:
					emit_signal("RMB_item", self, significant_data, insignificant_data, hand_node.significant_data, hand_node.insignificant_data, true)
			else:
				#Если предметы совпадают - объеденяем
				#Если не совпадают - меняем местами
				
				if not settings_slot["put_items"] or not settings_slot["take_items"]:
					return
				
				var dop = hand_node.insignificant_data.duplicate()
				if count == 2:
					dop["uni_quantity"] = 1
				var add_data = add_item(hand_node.significant_data, dop)
				
				if add_data[0] == false: #Меняем местами
					if settings_slot["valid_types"].size() <= 0 or str(hand_node.significant_data.get("type")) in settings_slot["valid_types"]:
						var dopi = [significant_data.duplicate(), insignificant_data.duplicate()]
						var get_data = get_item(true)
						
						set_item(add_data[1].duplicate(), hand_node.insignificant_data.duplicate())
						
						if dopi[0].hash() == default_significant_data.hash() and dopi[1].hash() == default_insignificant_data.hash():
							hand_node.significant_data = hand_node.get_node("HandSlot").default_significant_data.duplicate(true)
							hand_node.insignificant_data = hand_node.get_node("HandSlot").default_insignificant_data.duplicate(true)
						else:
							hand_node.significant_data = get_data[0]
							hand_node.insignificant_data = get_data[1]
						
						item_connecting()
						if count == 1:
							emit_signal("LMB_item", self, significant_data, insignificant_data, hand_node.significant_data, hand_node.insignificant_data, null)
						else:
							emit_signal("RMB_item", self, significant_data, insignificant_data, hand_node.significant_data, hand_node.insignificant_data, null)
				else: #Объединяем
					if count == 1:
						hand_node.significant_data = add_data[1]
						hand_node.insignificant_data = add_data[2]
					else:
						hand_node.insignificant_data["uni_quantity"] -= 1
						if int(hand_node.insignificant_data["uni_quantity"]) <= 0:
							hand_node.significant_data = hand_node.get_node("HandSlot").default_significant_data.duplicate(true)
							hand_node.insignificant_data = hand_node.get_node("HandSlot").default_insignificant_data.duplicate(true)
		
		hand_node.data_updated()
		installation_item()


#Стандартные функции

#При вызове отключает/подключает слот к умным предметам
func item_connecting():
	# 	В интерфейсе не забыть вызывать эту функцию
	#var connecting_nodes = [] #записываем все подключенные к нашим сигналам ноды
	for i in get_signal_list():
		for j in get_signal_connection_list(i["name"]):
			if str(j["callable"].get_object().get_path()).begins_with("/root/rootGame/Node/SettingData/ItemLogical/") and(significant_data.get("item") == null or j["callable"].get_object().name != significant_data["item"]):
				disconnect(j["signal"], Callable(j["callable"], j["method"]))
	
	if significant_data.get("item") == null: return
	
	var item_node = get_node_or_null("/root/rootGame/Node/SettingData/ItemLogical/" + str(significant_data.get("item")))
	
	#Подключаем ноду которая имеет имя нашего предмета
	if item_node != null and item_node.get_script() != null:
		for i in get_signal_list():
			for j in item_node.get_script().get_script_method_list():
				if i["name"] == j["name"]:
# warning-ignore:return_value_discarded
					connect(i["name"], Callable(item_node, j["name"]))
					break

#Добавляет предмет при условии что это возможно
#А так же полноценно объединяет предметы
#Возвращает True даже если объединить получилось не полностью
func add_item(significant, insignificant):
	var stack = [clamp(significant.get("maximum_number", 999999999999), 1, 999999999)]
	if settings_slot["slot_capacity"] != -1:
		stack.append(clamp(settings_slot["slot_capacity"], 1, 999999999))
	stack = float(stack.min())
	
	if (settings_slot["valid_types"].size() <= 0 or str(significant.get("type", "thing")) in settings_slot["valid_types"]) and insignificant.has("uni_quantity") and(significant_data.hash() == default_significant_data.hash() or significant.hash() == significant_data.hash()):
		#Так как некоторые данные содержат null, заранее обрабатыванем данные
		var data = [insignificant.get("uni_quantity"), insignificant_data.get("uni_quantity")]
		if not data[0] is int or data[0] <= 0: return [false, significant, insignificant, 0]
		if not data[1] is int: data[1] = 0
		if data[1] >= stack and significant_data.hash() != default_significant_data.hash(): return [false, significant, insignificant, 0]
		
		var procent = clamp((stack - data[1]) / data[0], 0, 1) #0.625% = ((6-1)/8)
		if significant_data.hash() == default_significant_data.hash():
			procent = int(stack - data[0]) #1 - 15 = -14 или 6 - 4 = 2
			if procent < 0:
				procent = int(data[0] - (procent * -1)) #15 - (-14 * -1) = 15 - 14 = 1
			else: procent = data[0]
		
		var add = procent
		if significant_data.hash() != default_significant_data.hash():
			add = int(data[0] * procent) #8 * 0.625
		
		if add <= 0 and significant_data.hash() != default_significant_data.hash():
			return [false, significant, insignificant, procent]
		
		if significant_data.hash() != default_significant_data.hash():
			insignificant_data["uni_quantity"] = data[1] + add
			insignificant["uni_quantity"] = data[0] - add
		else:
			insignificant_data = insignificant.duplicate(true)
			insignificant_data["uni_quantity"] = add #5 из 15
			insignificant["uni_quantity"] -= add #15 - 5 = 10
		
		significant_data = significant
		
		for i in insignificant.keys():
			if insignificant_data.has(i):
				if i.begins_with("re_"):
					insignificant_data[i] = insignificant[i]
				elif i.begins_with("uni_") and not insignificant[i] is bool and i != "uni_quantity":
					insignificant_data[i] += insignificant[i]
			else:
				insignificant_data[i] = insignificant[i]
		
		if settings_slot["multiplayer_synchronization"] == true:
			rpc("set_item", significant_data, insignificant_data)
			rpc("installation_item")
		
		if insignificant["uni_quantity"] <= 0:
			significant = {}
			insignificant = {}
		
		return [true, significant, insignificant, procent]
	return [false, significant, insignificant, 0]

#Добавляет предмет принудительно
@rpc("any_peer")
func set_item(significant, insignificant):
	emit_signal("set_item", self, significant_data, insignificant_data)
	significant_data = significant
	insignificant_data = insignificant
	if settings_slot["multiplayer_synchronization"] == true:
		rpc("set_item", significant_data, insignificant_data)
		rpc("installation_item")

#Опустошает слот, возвращает удаленные данные
#mode == true -- опусташаем полностью, mode == false -- только половину
func get_item(mode:bool = true):
	var data = [significant_data.duplicate(), insignificant_data.duplicate()]
	if mode == true:
		significant_data = default_significant_data.duplicate()
		insignificant_data = default_insignificant_data.duplicate()
	elif insignificant_data.has("uni_quantity"):
		var q = float(insignificant_data["uni_quantity"])/2
		
		insignificant_data["uni_quantity"] = int(q)
		data[1]["uni_quantity"] = int(round(q))
		
		if insignificant_data["uni_quantity"] <= 0:
			significant_data = default_significant_data.duplicate()
			insignificant_data = default_insignificant_data.duplicate()
	if settings_slot["multiplayer_synchronization"] == true:
		rpc("set_item", significant_data, insignificant_data)
		rpc("installation_item")
	return data

#Применяет к нодам имеющиеся данные
@rpc("any_peer") func installation_item():
	$Scales/Health.visible = not settings_slot["hide_health"]
	$Scales/Quantity.visible = not settings_slot["hide_quantity"]
	$Scope.visible = not settings_slot["hide_scope"]
	$Background.visible = not settings_slot["hide_background"]
	if significant_data.size() > 0:
		$AnimEvent.wait_time = significant_data["animation"]["event"]
		$Texture2D.texture = load(significant_data["animation"]["frames"][0])
		if significant_data["animation"].has("texture_flip_h"):
			$Texture2D.flip_h = significant_data["animation"]["texture_flip_h"]
		else:
			$Texture2D.flip_h = settings_slot["texture_flip_h"]
		if significant_data["animation"].has("texture_flip_v"):
			$Texture2D.flip_v = significant_data["animation"]["texture_flip_v"]
		else:
			$Texture2D.flip_v = settings_slot["texture_flip_v"]
		if insignificant_data["uni_quantity"] <= 999999999:
			$Scales/Quantity.text = var_to_str(insignificant_data["uni_quantity"])
		else:
			$Scales/Quantity.text = ">999млн"
		if insignificant_data["uni_quantity"] <= 1:
			$Scales/Quantity.hide()
		else:
			$Scales/Quantity.show()
		
		$Scales/Health.max_value = significant_data["health"]["maximum"]
		$Scales/Health.value = significant_data["health"]["current"]
		if significant_data["health"]["current"] >= significant_data["health"]["maximum"] or 0 > significant_data["health"]["current"]:
			$Scales/Health.hide()
		else:
			$Scales/Health.show()
		var color_code = significant_data["health"]["current"]*(255/significant_data["health"]["maximum"])
		$Scales/Health.get("theme_override_styles/fg").bg_color = Color8(255-color_code, color_code, 0, 255)
	else:
		$Scales/Health.hide()
		$Scales/Health.value = 0
		$Scales/Health.max_value = 100
		$Scales/Quantity.hide()
		$Scales/Quantity.text = "0"
		$Texture2D.texture = null
		$AnimEvent.wait_time = 1
		
		$Texture2D.flip_h = settings_slot["texture_flip_h"]
		$Texture2D.flip_v = settings_slot["texture_flip_v"]

#Восстанавливает пробелы, такие как отцуцтвие текстуры или количества
#Пробелы в данных попытается восполнить информацией из SD, если такая там присуцтвует
#Не принимает полностью пустой словарь, т.к. пустой словарь - отцуцтвие предмета
#Если он получит словарь в котором нет item - вернёт {}
func data_repair(significant:Dictionary, insignificant:Dictionary):
	SD = get_node_or_null("/root/rootGame/Node/SettingData")
	
	
	if not significant.has("item") or significant["item"] == null:
		return [{}, {}]
	var item_in_SD = SD.get_node_or_null("ItemData").get(significant["item"])
	
	if not significant.has("description"):
		if item_in_SD is Dictionary and item_in_SD.has("name_in_game") and item_in_SD.has("description"):
			significant["description"] = item_in_SD["name_in_game"] + "\n\n" + item_in_SD["description"]
		elif item_in_SD is Dictionary and item_in_SD.has("name_in_game"):
			significant["description"] = item_in_SD["name_in_game"]
		elif item_in_SD is Dictionary and item_in_SD.has("description"):
			significant["description"] = item_in_SD["description"]
		elif significant.has("name_in_game"):
			significant["description"] = significant["name_in_game"]
		else:
			significant["description"] = significant["item"]
	if not significant.has("name_in_game"):
		if item_in_SD is Dictionary and item_in_SD.has("name_in_game"):
			significant["name_in_game"] = item_in_SD["name_in_game"]
		else:
			significant["name_in_game"] = significant["item"]
	if not insignificant.has("uni_quantity") or(insignificant.has("uni_quantity") and not insignificant["uni_quantity"] is int):
		if insignificant.has("uni_quantity") and (insignificant["uni_quantity"] is Vector2 or insignificant["uni_quantity"] is Vector3):
			insignificant["uni_quantity"] = int(insignificant["uni_quantity"].x)
		else:
			insignificant["uni_quantity"] = 1
	if not significant.has("animation"):
		if item_in_SD is Dictionary and item_in_SD.has("animation"):
			significant["animation"] = item_in_SD["animation"]
		else:
			significant["animation"] = {"event": 1, "frames": ["res://textures/black.png"]}
	if not significant.has("health"):
		if item_in_SD is Dictionary and item_in_SD.has("health"):
			significant["health"] = item_in_SD["health"]
		else:
			significant["health"] = {"current": 100, "maximum": 100}
	if significant["health"] is Vector2 or significant["health"] is Vector3:
		significant["health"] = {"current": significant["health"].y, "maximum": 100}
	if not significant.has("maximum_number"):
		if item_in_SD is Dictionary and item_in_SD.has("maximum_number"):
			significant["maximum_number"] = item_in_SD["maximum_number"]
		else:
			significant["maximum_number"] = 1
	if not significant.has("type"):
		if item_in_SD is Dictionary and item_in_SD.has("type"):
			significant["type"] = item_in_SD["type"]
		else:
			significant["type"] = "thing"
	if not significant.has("output"):
		if item_in_SD is Dictionary and item_in_SD.has("output"):
			significant["output"] = item_in_SD["output"]
		else:
			significant["output"] = 0
	
	return [significant, insignificant]

#Обновляет спрайт текстуры
func anim_event():
	$Texture2D.flip_h = settings_slot["texture_flip_h"]
	$Texture2D.flip_v = settings_slot["texture_flip_v"]
	if insignificant_data.has("not_anim_id") and insignificant_data["not_anim_id"] is int and significant_data.has("animation") and significant_data["animation"]["frames"].size() - 1 >= insignificant_data["not_anim_id"]:
		$Texture2D.texture = load(significant_data["animation"]["frames"][insignificant_data["not_anim_id"]])
		insignificant_data["not_anim_id"] += 1
	else:
		if significant_data.has("item"):
			if significant_data.has("animation") and significant_data["animation"].has("frames"):
				$Texture2D.texture = load(significant_data["animation"]["frames"][0])
			else:
				$Texture2D.texture = load("res://textures/black.png")
			insignificant_data["not_anim_id"] = 0


#Дополнительные функции (не работают если предмета в слоте нет)

#Изменяет здоровье
#Если переданна цифра:
	#текущее_здоровье = clamp(текущее_здоровье - health, 0, макс_здоровье)
#Если передан Vector:
	#текущее_здоровье["current"] = clamp(health["current"], -1, health["maximum"])
	#Будет изменён предел здоровья предмета
#Если здоровье предмета -1, то он бесмертный и 1 режим на него не действует
#Если здоровье предмета станет 0, то он будет удалён вне зависимости от режима
func change_health(health):
	if health is float or health is int:
		significant_data["health"]["current"] = clamp(significant_data["health"]["current"] - health, 0, significant_data["health"]["maximum"])
	elif health is Dictionary:
		significant_data["health"] = {"maximum": health["maximum"], "current": clamp(health["current"], -1, health["maximum"])}
	
	if significant_data["health"]["current"] == 0 or significant_data["health"]["current"] < -1:
		significant_data = default_significant_data.duplicate()
		insignificant_data = default_insignificant_data.duplicate()
		item_connecting()
	installation_item()

#Изменяет анимацию
#Пример анимации:
#{"event": 1, "frames": ["res://icon.png"]}
#event - скорость переключения кадров (в секундах)
#frames - массив кадров анимации
func change_anim(anim: Dictionary, key = 0.0): #anim - устанавливаймая анимация, key - ключ с которого запустить анимацию
	if anim.has("event") and(anim["event"] is int or anim["event"] is float) and anim.has("frames") and anim["frames"] is Array and anim["frames"].size() > 0:
		key = clamp(float(key), 0.0, float(anim["frames"].size()-1))
		insignificant_data["not_anim_id"] = key+1
		$Texture2D.texture = load(significant_data["animation"]["frames"][key])
		return true
	return false

#Изменяет описание
#title - заголовок, "" - значит отцуцтвует
#text - заголовок, "" - значит отцуцтвует
#При отцуцтвии обоих параметров описание будет удалено
func change_description(title:String = "", text:String = ""):
	var des = ""
	if title != "":
		des = title
	if text != "":
		if des != "":
			des += "\n\n"
		des += text
	significant_data["description"] = des
	self.tooltip_text = significant_data["description"]

#Изменяет русской название предмета, адресата изменить невозможно!!!
#Если name_item пуст, то изменения не вступят в силу
func change_name(name_item:String = ""):
	if name_item != "":
		significant_data["name_in_game"] = name_item
		return true
	return false

#Устанавливает количество предметов в слоте, если 0 - предмет будет удалён
#Минимальное доступное значение - 0, максимальное - 999999999 (999млн.)
#mode true - uni_quantity = clamp(quantity, 0, 999999999)
#mode false - uni_quantity = clamp(uni_quantity - quantity, 0, 999999999)
func change_quantity(quantity:int = 1, mode:bool = true):
	if mode == true:
		insignificant_data["uni_quantity"] = clamp(quantity, 0, 999999999)
	else:
		insignificant_data["uni_quantity"] = clamp(insignificant_data["uni_quantity"] - quantity, 0, 999999999)
	if insignificant_data["uni_quantity"] <= 0:
		insignificant_data = default_insignificant_data.duplicate()
		significant_data = default_significant_data.duplicate()
		installation_item()
	else:
		if insignificant_data["uni_quantity"] <= 999999999:
			$Scales/Quantity.text = var_to_str(insignificant_data["uni_quantity"])
		else:
			$Scales/Quantity.text = ">999млн"
		if insignificant_data["uni_quantity"] <= 1:
			$Scales/Quantity.hide()
		else:
			$Scales/Quantity.show()
	item_connecting()

#Изменяет класс предмета, поддерживаются кастомные классы
#Если type пуст, то изменения не вступят в силу
#Если type не поддерживается слотом, то изменения не вступят в силу
func change_type(type:String = ""):
	if type != "" and(settings_slot["valid_types"].size() <= 0 or type in settings_slot["valid_types"]):
		significant_data["type"] = type
		return true
	return false

#Изменит размер стака, а так же уменьшит количество предметов в слоте если они превышают стак
#Минимальное доступное значение - 1, максимальное - 999999999 (999млн.)
func change_stack(stack = 1.0):
	stack = clamp(float(stack), 1.0, 999999999.0)
	significant_data["maximum_number"] = stack
	insignificant_data["uni_quantity"] = clamp(insignificant_data["uni_quantity"], 0, stack)
	if insignificant_data["uni_quantity"] <= 0:
		insignificant_data = default_insignificant_data.duplicate()
		significant_data = default_significant_data.duplicate()
		installation_item()
	else:
		if insignificant_data["uni_quantity"] <= 999999999:
			$Scales/Quantity.text = var_to_str(insignificant_data["uni_quantity"])
		else:
			$Scales/Quantity.text = ">999млн"
		if insignificant_data["uni_quantity"] <= 1:
			$Scales/Quantity.hide()
		else:
			$Scales/Quantity.show()
