extends KinematicBody2D

# Справка
# 0 = Рука
# 1 = Самопал
# 2 = Миниган
# 3 = Снайперка
# 4 = Магнитка
# 5 =
export var in_hand:int = 0

# Справка
# 0 = пусто
# 19 = джинсы - 1
# 25 = 
export var on_foot:int = 0

# Справка
# 0 = пусто
# 13 = толстовка - 1
# 30 = 
export var on_the_chest:int = 0

export var armor = 0 #Уровень поглащения урона 0-100

#Инвентарь (крафт)
export var minigun:int = 0 #Пушка миниган
export var samopal:int = 0 #Пушка самопал
export var sniper:int = 1 #Пушка снайперка
export var magnetic_cannon:int = 1 #Магнитная пушка
export var bullets_SAM:int = 10 #Пули для маленьких стволов
export var bullets_MGAN:int = 25 #Пули для средних стволов
export var bullets_magnit:int = 14 #Магнитики

#Инвентарь (не крафтиться)
export var jeans:int = 1 #Джинсы
export var hoody:int = 1 #Толстовка
export var fuel:int = 160 #Топливо

#Инвентарь (сырые)
export var metal:int = 10 #Металл
export var food:int = 10 #Еда
export var components:int = 10 #Компоненты
export var wood:int = 15 #Дерево
export var electronics:int = 10 #Электроника

export var timMAT:bool = false
export var vrema:bool = true
export var otbros:int
export var sbros:bool = true
export var otscoc:bool = false
export var col_priscov:int = 3
export var pravo:bool = true

export var osobZAMED:int = 0

export var mohed_spat:bool = true

export onready var SettingData = $"/root/rootGame/Node/SettingData"

export var sdorov = 5.0 #макс 5.0
export var golod = 20.0 #макс 20.0
export var sleep = 0.0 #макс 2.0

export var UI = {
	"intermeny": false,
	"vcl": false,
	"osob": false
}

export var ymer:bool = false

export var golodyha:bool = false
export var visota:bool = false
export var noSleep:bool = false

export var anm:String = ""
export var lst:String = ""

#Может ли объект препятствовать закрытию объектов
const stopping_gates = true

#Константы перемешения
const yX:int = 3
const X:int = 260
const notY:int = 15
const Y:int = 500

#Передвижение игрока
var ZAMED = 0
export var inventory_weight = 0.0

var game:bool = false

#Дополнительные переменные физики
export var fisic = Vector2()
export var smot = Vector2(0,-1)

func peresot():
	inventory_weight = metal + food + components/2 + wood + electronics/2 + bullets_MGAN/3.5 + bullets_SAM/4 + samopal*4 + sniper*11 + jeans/2.5 + hoody/2.5 + fuel/15 + magnetic_cannon*10 + bullets_magnit/3
	armor = on_foot + on_the_chest
	if armor > 100: armor = 100

func _ready():
	if get_node("/root/editmap"):
		return
	else:
		game = true
	#Какаета фигня для использования
	$RayCast2D2.add_exception(self)
	
	print(get_node("/root/rootGame/Node/SettingData"))
	$GolodHp.wait_time = get_node("/root/rootGame/Node/SettingData").taking_away_hunger
	$SleepEvent.wait_time = get_node("/root/rootGame/Node/SettingData").fatigue_frequency

func _input(_event):
	#Проверка запущена ли сцена редактора карт
	if game == false:
		return
	
	#Дебафы и бафы при носке оружия
	if in_hand == 1:
		$Timer.wait_time = 3
		osobZAMED = 11
		$Camera2D.zoom.x = 1
		$Camera2D.zoom.y = 1
	elif in_hand == 2:
		$Timer.wait_time = 0.3
		osobZAMED = 55
		$Camera2D.zoom.x = 1
		$Camera2D.zoom.y = 1
	elif in_hand == 3:
		$Timer.wait_time = 4.5
		osobZAMED = 160
		$Camera2D.zoom.x = 1.5
		$Camera2D.zoom.y = 1.5
	elif in_hand == 4:
		$Timer.wait_time = 0.35
		osobZAMED = 40
		$Camera2D.zoom.x = 1
		$Camera2D.zoom.y = 1
	else:
		osobZAMED = 0
		$Camera2D.zoom.x = 1
		$Camera2D.zoom.y = 1
	
	if get_node("Camera2D/Interfes/Interf").visible == true:
		#Использовать
		if Input.is_action_just_pressed("Use"):
			var areas = $UseArea.get_overlapping_areas() # получить все Area2D, с которыми пересекается UseArea игрок
			var bodis = $UseArea.get_overlapping_bodies()
			for area in areas:
				if area.has_method("use"):  # если эту "Area2D" можно использовать, то используем ее только одну (чтобы не юзать несколько пересекающихся зон разом)
					area.use(self)
					break
			for bodi in bodis:
				if bodi.has_method("use_b"):
					bodi.use_b(self, sdorov, golod, sleep)
					break
		
		#Стрельба
		#С таймдауном
		if Input.is_action_just_pressed("attac"):
			if G.puliSAM >= 1 and G.VRuke == 1 and vrema == true:
				var pulain = pula.instance()
				pulain.damag = 1
				pulain.povorot = pravo
				otbros = 350
				if pravo == true and not $RayCast2D4.is_colliding():
					pulain.position = $Position2D.global_position
					get_parent().add_child(pulain)
					G.puliSAM = G.puliSAM - 1
					G.peresot()
					vrema = false
					$Timer.start()
					fisic.x -= otbros
				
				elif pravo == false and not $RayCast2D3.is_colliding():
					pulain.position = $Position2D2.global_position
					get_parent().add_child(pulain)
					G.puliSAM = G.puliSAM - 1
					G.peresot()
					vrema = false
					$Timer.start()
					fisic.x += otbros
			elif G.puliSAM >= 1 and G.VRuke == 3 and vrema == true:
				var pulain = pula.instance()
				pulain.damag = 1.5
				pulain.osob = true
				pulain.povorot = pravo
				otbros = 700
				if pravo == true and not $RayCast2D4.is_colliding():
					pulain.position = $Position2D.global_position
					get_parent().add_child(pulain)
					G.puliSAM = G.puliSAM - 1
					G.peresot()
					vrema = false
					$Timer.start()
					fisic.x -= otbros
				
				elif pravo == false and not $RayCast2D3.is_colliding():
					pulain.position = $Position2D2.global_position
					get_parent().add_child(pulain)
					G.puliSAM = G.puliSAM - 1
					G.peresot()
					vrema = false
					$Timer.start()
					fisic.x += otbros

func _physics_process(_delta):
	if game == false:
		return
	
	if inventory_weight <= 0:
		ZAMED = 0
	elif inventory_weight >= 40:
		ZAMED = inventory_weight
	else:
		ZAMED = 0
	
	#get_node("Camera2D/Interfes/blur").material.set_shader_param("a", sleep)
	
	den_noh_cl()
	
	if fisic.y >= 600 and sbros == true and $RayCast2D.is_colliding():
		var plusi
		var yr
		sbros = false
		
		plusi = fisic/500
		
		yr = plusi
		
		print(fisic.y)
		print(yr)
		
		if yr >= sdorov:
			visota = true
		
		sdorov = sdorov - yr
	
	if !is_on_floor():
		sbros = true
	
	if is_on_floor():
		otscoc = false
		col_priscov = 3
	if is_on_wall():
		otscoc = true
	if !is_on_floor() and !is_on_wall():
		$Timer3.start()
	
	#if get_node("Camera2D/Interface/main").visible == true:
	#	#Стрельба
	#	#Без таймдаун
	#	if Input.is_action_pressed("attac"):
	#		if G.puliMGAN >= 1 and G.VRuke == 2 and vrema == true:
	#			var pulainM = pula.instance()
	#			pulainM.damag = 0.1
	#			pulainM.povorot = pravo
	#			otbros = 150
	#			if pravo == true and not $RayCast2D4.is_colliding():
	#				pulainM.position = $Position2D.global_position
	#				get_parent().add_child(pulainM)
	#				G.puliMGAN = G.puliMGAN - 1
	#				G.peresot()
	#				vrema = false
	#				$Timer.start()
	#				fisic.x -= otbros
	#			
	#			elif pravo == false and not $RayCast2D3.is_colliding():
	#				pulainM.position = $Position2D2.global_position
	#				get_parent().add_child(pulainM)
	#				G.puliMGAN = G.puliMGAN - 1
	#				vrema = false
	#				G.peresot()
	#				$Timer.start()
	#				fisic.x += otbros
	#		elif G.magnit >= 1 and G.VRuke == 4 and vrema == true:
	#			var mag = magnit.instance()
	#			mag.povorot = pravo
	#			otbros = 150
	#			if pravo == true and not $RayCast2D4.is_colliding():
	#				mag.position = $Position2D.global_position
	#				get_parent().add_child(mag)
	#				G.magnit -= 1
	#				G.peresot()
	#				vrema = false
	#				$Timer.start()
	#				fisic.x -= otbros
	#			
	#			elif pravo == false and not $RayCast2D3.is_colliding():
	#				mag.position = $Position2D2.global_position
	#				get_parent().add_child(mag)
	#				G.magnit -= 1
	#				vrema = false
	#				G.peresot()
	#				$Timer.start()
	#				fisic.x += otbros
	
	#Передвижение по X (ходьба)
	if Input.is_action_pressed("a") and get_node("Camera2D/Interfes/Interf").visible == true and Input.is_action_pressed("d") and(is_on_floor() or $RayCast2D.is_colliding()):
		pass
	elif Input.is_action_pressed("a") and get_node("Camera2D/Interfes/Interf").visible == true and(is_on_floor() or $RayCast2D.is_colliding()):
		fisic.x = -(X - ((G.ZAMED + osobZAMED)/5))
		pravo = false
	elif Input.is_action_pressed("d") and get_node("Camera2D/Interfes/Interf").visible == true and(is_on_floor() or $RayCast2D.is_colliding()):
		fisic.x = (X - ((G.ZAMED + osobZAMED)/5))
		pravo = true
	elif is_on_floor():
		fisic.x = 0
	
	if is_on_wall() and not is_on_floor() and col_priscov > 0:
		fisic.y = 0
	
	#Передвижение по X (полёт)
	if Input.is_action_pressed("a") and get_node("Camera2D/Interfes/Interf").visible == true and Input.is_action_pressed("d") and not is_on_floor():
		pass
	elif Input.is_action_pressed("a") and get_node("Camera2D/Interfes/Interf").visible == true and not is_on_floor():
		fisic.x -= yX * 2
		pravo = false
	elif Input.is_action_pressed("d") and get_node("Camera2D/Interfes/Interf").visible == true and not is_on_floor():
		fisic.x += yX * 2
		pravo = true
	
	#Прыжок и "претежение"
	if Input.is_action_pressed("w") and get_node("Camera2D/Interfes/Interf").visible == true and otscoc == true and not is_on_wall() and col_priscov > 0:
		fisic.y -= Y - ((G.ZAMED + osobZAMED)/12)
		timMAT = true
		otscoc = false
		col_priscov -= 1
		$Timer2.start()
		if ZAMED > 0 and golod > 0:
			golod -= 0.7
	elif Input.is_action_pressed("w") and get_node("Camera2D/Interfes/Interf").visible == true and timMAT == false and is_on_floor():
		fisic.y -= Y - ((G.ZAMED + osobZAMED)/12)
		timMAT = true
		otscoc = false
		$Timer2.start()
		if ZAMED > 0 and golod > 0:
			golod -= 0.3
	elif !is_on_floor():
		fisic.y += notY + ((ZAMED + osobZAMED)/15)
	
	if Input.is_action_pressed("s") and get_node("Camera2D/Interfes/Interf").visible == true:
		fisic.y += 15 + ((ZAMED + osobZAMED)/4)
	
	#Физика
	fisic = move_and_slide(fisic, smot, false, 4, PI/4, false)

func show_workbench_window(_workbench):
	#Открытие меню крафта
	get_node("Camera2D/Interfes/CraftMeny").show()
	get_node("Camera2D/Interfes/MenyInter").show()
	get_node("Camera2D/Interfes/Nadeto").hide()
	get_node("Camera2D/Interfes/Interf").hide()
	get_node("Camera2D/Interfes/Meny").hide()
	UI.vcl = false
	UI.intermeny = true
	#Ставим на паузу
	get_tree().paused = true

func Timer_timeout():
	vrema = true

func yron(_workbench):
	sdorov -= 1 - G.bron / 100

func jump_timeout():
	timMAT = false

func otscoc_timeout():
	otscoc = false

func spit(timeV): #timeV - на сколько игрок ложиться спать
	print("Игрок спит")
	sleep = sleep - (timeV/9)
	
	sdorov = sdorov + (timeV/3)
	golod = golod - (timeV/2)
	
	if sdorov > 5:
		sdorov = 5
	if golod < 0:
		golod = 0
	get_node("/root/rootGame").file_save()

func den_noh_cl():
	anm = "Hoh-den"
	if SettingData.time <= 5 or SettingData.time >= 17:
		anm = "Den-noh"
	if not anm == lst:
		$AnimationPlayer.play(anm)
		lst = anm

func spat(_gg):
	get_node("Camera2D/Interfes/CraftMeny").hide()
	get_node("Camera2D/Interfes/CrovatM").show()
	get_node("Camera2D/Interfes/Interf").hide()
	get_node("Camera2D/Interfes/Meny").hide()
	get_node("Camera2D/Interfes/Nadeto").hide()
	get_node("Camera2D/Interfes/MenyInter").show()
	UI["intermeny"] = true
	UI["vcl"] = false

func sahod_hatl(_g):
	queue_free()

func show_comp():
	UI["osob"] = true
	get_node("Camera2D/Interfes/Comp").show()
	get_node("Camera2D/Interfes/Interf").hide()

func GolodHp_timeout():
	if golod > 0 and sdorov > 0:
		golod = golod - 1
		if golod >= 11 and sdorov <= 4:
			sdorov = sdorov + 1
			golod = golod - 1
	
	elif golod <= 0 and sdorov >= 1:
		if sdorov == 1:
			golodyha = true
		sdorov = sdorov - 1
	else:
		golod = 0
		sdorov = 0
		golodyha = true

func Sleep_timeout():
	print("Инфа ", get_node("Camera2D/Interfes/blur").material.get_shader_param("a"))
	sleep += 0.1
	print("Сонливость ", sleep)
	if sleep > 2.0:
		ymer = true
		noSleep = true
