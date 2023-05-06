extends Control

#Путь до нод инвентаря
onready var CraftMeny: Control = $"../CraftMeny" #две точки - это шаг выше по иерархии, то есть - "перейди к владельцу и в нем найди ноду Interf"
onready var Interf: Control = $"../Interf"
onready var Nadeto: Control = $"../Nadeto"
onready var Meny: Control = $"../Meny"
onready var NadetoRect: Control = $"../Nadeto/ColorRect8/ColorRect2"
onready var NadetoRectVnoge = $"../Nadeto/ColorRect7/Sprite"
onready var NadetoRectVgrudi: Control = $"../Nadeto/ColorRect7/ColorRect"
onready var NadetoStatistic: Control = $"../Nadeto/ColorRect4/Label2"
onready var CrovatM: Control = $"../CrovatM"

onready var GG = get_node("../../../../GG")

func _process(_delta):
	NadetoStatistic.text = str(G.bron) + "%"
	
	if G.ru == true:
		$SecInventori.text = "Ваш рюкзак весит: " + str(round(G.SecInventori/4)) + ",  Перегрузка оценивается в: " + str(round(G.ZAMED/10))
	else:
		$SecInventori.text = "Your backpack weighs: " + str(round(G.SecInventori/4)) + ",  Overload is estimated at: " + str(round(G.ZAMED/10))
	
	if G.Vnoge == 0:
		NadetoRectVnoge.hide()
	elif G.Vnoge == 19:
		NadetoRectVnoge.show()
		var dj = load("res://Tecture/Modeli/djuns.png")
		NadetoRectVnoge.texture = dj
	else:
		NadetoRectVnoge.hide()
	
	if G.Vgrudi == 0:
		NadetoRectVgrudi.color = Color("00000000")
	elif G.Vgrudi == 13:
		NadetoRectVgrudi.color = Color("ff006c")
	else:
		NadetoRectVgrudi.color = Color("00000000")
	
	if G.VRuke == 0:
		NadetoRect.color = Color("00000000")
	elif G.VRuke == 1:
		NadetoRect.color = Color("8500ff")
	elif G.VRuke == 2:
		NadetoRect.color = Color("1918b0")
	elif G.VRuke == 3:
		NadetoRect.color = Color("0093ff")
	elif G.VRuke == 4:
		NadetoRect.color = Color("ff0078")

func _ready():
	if G.ru == false:
		$MenyTab1/GridContainer/ComponentInventori/Button2.text = "delete"
		$MenyTab1/GridContainer/DerevoInventori/Button2.text = "delete"
		$MenyTab1/GridContainer/EdaInventori/Button2.text = "delete"
		$MenyTab1/GridContainer/EdaInventori/Button.text = "use"
		$MenyTab1/GridContainer/ElictronicInventori/Button2.text = "delete"
		$MenyTab1/GridContainer/MetallInventori/Button2.text = "delete"
		
		$MenyTab2/GridContainer2/GovnoGAN/Button2.text = "delete"
		$MenyTab2/GridContainer2/miniGAN/Button2.text = "delete"
		$MenyTab2/GridContainer2/PuliM/Button.text = "delete"
		$MenyTab2/GridContainer2/PuliSAM/Label.text = "bullets S.A.m"
		$MenyTab2/GridContainer2/PuliM/Label.text = "bullets m.GAN"
		$MenyTab2/GridContainer2/PuliSAM/Button.text = "delete"
		$MenyTab2/GridContainer2/GovnoGAN/Label.text = "samopal"
		$MenyTab2/GridContainer2/miniGAN/Label.text = "minigun"
		$MenyTab2/ScrollContainer/GridContainer2/Snaper/Button2.text = "delete"
		$MenyTab2/ScrollContainer/GridContainer2/Snaper/Label.text = "sniper rifle"
		
		$MenyTab1/GridContainer/EdaInventori/Label.text = "food:"
		$MenyTab1/GridContainer/DerevoInventori/Label.text = "Wood:"
		$MenyTab1/GridContainer/ComponentInventori/Label.text = "Component:"
		$MenyTab1/GridContainer/ElictronicInventori/Label.text = "Electronic:"
		$MenyTab1/GridContainer/MetallInventori/Label.text = "metal:"
		$MenyTab1/GridContainer/ComponentInventori/Label2.rect_position.x = 83
		$MenyTab1/GridContainer/ElictronicInventori/Label2.rect_position.x = 84

func _input(_event):
	#Открываем интерфейс
	if Input.is_action_just_pressed("OpenInvetori") and GG.ymer == false and GG.UI["osob"] == false:
		if GG.UI["vcl"] == true:
			Meny.hide()
			GG.UI["vcl"] = false
		else:
			if $".".visible == true:
				$".".hide()
				GG.UI["intermeny"] = false
				CraftMeny.hide()
				Nadeto.hide()
				Meny.hide()
				CrovatM.hide()
				GG.UI["vcl"] = false
				Interf.show()
			
			elif $".".visible == false:
				if GG.UI["vcl"] == true:
					Meny.hide()
					GG.UI["vcl"] = false
				else:
					$".".show()
					Nadeto.show()
					CraftMeny.hide()
					Meny.hide()
					GG.UI["intermeny"] = true
					GG.UI["vcl"] = false
					Interf.hide()
	
	#Локальное обновление
	if G.VRuke == 1:
		if G.ru == true:
			$MenyTab2/ScrollContainer/GridContainer2/GovnoGAN/Button.text = "выбран"
		else:
			$MenyTab2/ScrollContainer/GridContainer2/GovnoGAN/Button.text = "selected"
	else:
		if G.ru == true:
			$MenyTab2/ScrollContainer/GridContainer2/GovnoGAN/Button.text = "выбрать"
		else:
			$MenyTab2/ScrollContainer/GridContainer2/GovnoGAN/Button.text = "select"
	
	if G.VRuke == 2:
		if G.ru == true:
			$MenyTab2/ScrollContainer/GridContainer2/miniGAN/Button.text = "выбран"
		else:
			$MenyTab2/ScrollContainer/GridContainer2/miniGAN/Button.text = "selected"
	else:
		if G.ru == true:
			$MenyTab2/ScrollContainer/GridContainer2/miniGAN/Button.text = "выбрать"
		else:
			$MenyTab2/ScrollContainer/GridContainer2/miniGAN/Button.text = "select"
	
	if G.VRuke == 3:
		if G.ru == true:
			$MenyTab2/ScrollContainer/GridContainer2/Snaper/Button.text = "выбран"
		else:
			$MenyTab2/ScrollContainer/GridContainer2/Snaper/Button.text = "selected"
	else:
		if G.ru == true:
			$MenyTab2/ScrollContainer/GridContainer2/Snaper/Button.text = "выбрать"
		else:
			$MenyTab2/ScrollContainer/GridContainer2/Snaper/Button.text = "select"
	
	if G.VRuke == 4:
		if G.ru == true:
			$MenyTab2/ScrollContainer/GridContainer2/MagnitGan/Button.text = "выбран"
		else:
			$MenyTab2/ScrollContainer/GridContainer2/MagnitGan/Button.text = "selected"
	else:
		if G.ru == true:
			$MenyTab2/ScrollContainer/GridContainer2/MagnitGan/Button.text = "выбрать"
		else:
			$MenyTab2/ScrollContainer/GridContainer2/MagnitGan/Button.text = "select"
	
	if G.Vnoge == 19:
		if G.ru == true:
			$MenyTab2/ScrollContainer/GridContainer2/Djuns/Button.text = "выбран"
		else:
			$MenyTab2/ScrollContainer/GridContainer2/Djuns/Button.text = "selected"
	else:
		if G.ru == true:
			$MenyTab2/ScrollContainer/GridContainer2/Djuns/Button.text = "выбрать"
		else:
			$MenyTab2/ScrollContainer/GridContainer2/Djuns/Button.text = "select"
	
	if G.Vgrudi == 13:
		if G.ru == true:
			$MenyTab2/ScrollContainer/GridContainer2/Tolstovca/Button.text = "выбран"
		else:
			$MenyTab2/ScrollContainer/GridContainer2/Tolstovca/Button.text = "selected"
	else:
		if G.ru == true:
			$MenyTab2/ScrollContainer/GridContainer2/Tolstovca/Button.text = "выбрать"
		else:
			$MenyTab2/ScrollContainer/GridContainer2/Tolstovca/Button.text = "select"

func pressed():
	$".".hide()
	CraftMeny.hide()
	Nadeto.hide()
	CrovatM.hide()
	Interf.show()

func pressed_use_eda():
	if GG.golod < 20:
		G.eda -= 1
		G.peresot()
		GG.golod += 1
		if GG.golod > 20:
			GG.golod = 20
	print(GG.golod)

func tab_2():
	$MenyTab1.hide()
	$MenyTab2.show()
	$Tab1.color = Color("171717")
	$Tab2.color = Color("2e2e2e")

func tab1():
	$MenyTab1.show()
	$MenyTab2.hide()
	$Tab1.color = Color("2e2e2e")
	$Tab2.color = Color("171717")

func pressed_samopal_vib():
	if G.VRuke == 1:
		G.VRuke = 0
	else:
		G.VRuke = 1

func pressed_minigan_vib():
	if G.VRuke == 2:
		G.VRuke = 0
	else:
		G.VRuke = 2

func ydal_eda_pressed():
	G.eda = G.eda - 1
	G.peresot()

func ydal_derevo_pressed():
	G.derevo = G.derevo - 1
	G.peresot()

func ydal_component_pressed():
	G.component = G.component - 1
	G.peresot()

func ydal_elictronic_pressed():
	G.electronic = G.electronic - 1
	G.peresot()

func ydal_metall_pressed():
	G.metall = G.metall - 1
	G.peresot()

func sbros_ruci():
	G.VRuke = 0

func samopal_del():
	G.samopal = 0
	G.peresot()
	if G.VRuke == 1:
		G.VRuke = 0

func minigan_del():
	G.minigan = 0
	if G.VRuke == 2:
		G.VRuke = 0
	G.peresot()

func puliSAM_del():
	G.puliSAM = G.puliSAM - 1
	G.peresot()

func puliM_del():
	G.puliMGAN = G.puliMGAN - 1
	G.peresot()

func sbros_nog():
	G.Vnoge = 0
	G.peresot()

func sbros_ruc():
	G.Vgrudi = 0
	G.peresot()

func tolstovca_del():
	G.tolstovca = 0
	if G.Vgrudi == 13:
		G.Vgrudi = 0
	G.peresot()

func djuns_del():
	G.djuns = 0
	if G.Vnoge == 19:
		G.Vnoge = 0
	G.peresot()

func djuns_use():
	if G.Vnoge == 19:
		G.Vnoge = 0
	else:
		G.Vnoge = 19
	G.peresot()

func tolstovca_use():
	if G.Vgrudi == 13:
		G.Vgrudi = 0
	else:
		G.Vgrudi = 13
	G.peresot()

func pressed_snaperca_vib():
	if G.VRuke == 3:
		G.VRuke = 0
	else:
		G.VRuke = 3

func pressed_snaperca_del():
	G.snaper = 0
	G.peresot()
	if G.VRuke == 3:
		G.VRuke = 0

func pressed_magnitca_vib():
	if G.VRuke == 4:
		G.VRuke = 0
	else:
		G.VRuke = 4

func pressed_magnitca_del():
	G.magnitGan = 0
	G.peresot()
	if G.VRuke == 4:
		G.VRuke = 0

func ydal_toplivo_pressed():
	G.toplivo -= 1

func ydal_toplivo_10_pressed():
	if G.toplivo >= 10:
		G.toplivo -= 10

func magniti_del():
	G.magnit -= 1
