extends Control

onready var ElictronicInventori: Control = $"../MenyInter/MenyTab1/GridContainer/ElictronicInventori"
onready var ElictronicInventoriLabel: Control = $"../MenyInter/MenyTab1/GridContainer/ElictronicInventori/Label2"

onready var ComponentInventori: Control = $"../MenyInter/MenyTab1/GridContainer/ComponentInventori"
onready var ComponentInventoriLabel: Control = $"../MenyInter/MenyTab1/GridContainer/ComponentInventori/Label2"

onready var MetallInventori: Control = $"../MenyInter/MenyTab1/GridContainer/MetallInventori"
onready var MetallInventoriLabel: Control = $"../MenyInter/MenyTab1/GridContainer/MetallInventori/Label2"

onready var EdaInventori: Control = $"../MenyInter/MenyTab1/GridContainer/EdaInventori"
onready var EdaInventoriLabel: Control = $"../MenyInter/MenyTab1/GridContainer/EdaInventori/Label2"

onready var DerevoInventori: Control = $"../MenyInter/MenyTab1/GridContainer/DerevoInventori"
onready var DerevoInventoriLabel: Control = $"../MenyInter/MenyTab1/GridContainer/DerevoInventori/Label2"

onready var SamopalInventori: Control = $"../MenyInter/MenyTab2/ScrollContainer/GridContainer2/GovnoGAN"

onready var MiniganInventori: Control = $"../MenyInter/MenyTab2/ScrollContainer/GridContainer2/miniGAN"

onready var MagnitGanInventori: Control = $"../MenyInter/MenyTab2/ScrollContainer/GridContainer2/MagnitGan"

onready var TolstovcaInventori: Control = $"../MenyInter/MenyTab2/ScrollContainer/GridContainer2/Tolstovca"

onready var SnapercaInventori: Control = $"../MenyInter/MenyTab2/ScrollContainer/GridContainer2/Snaper"

onready var DjunsInventori: Control = $"../MenyInter/MenyTab2/ScrollContainer/GridContainer2/Djuns"

onready var PuliSAM: Control = $"../MenyInter/MenyTab2/ScrollContainer/GridContainer2/PuliSAM"
onready var PuliSAMLabel: Control = $"../MenyInter/MenyTab2/ScrollContainer/GridContainer2/PuliSAM/Label2"

onready var PuliMGan: Control = $"../MenyInter/MenyTab2/ScrollContainer/GridContainer2/PuliM"
onready var PuliMGANLabel: Control = $"../MenyInter/MenyTab2/ScrollContainer/GridContainer2/PuliM/Label2"

onready var ToplivoLabel: Control = $"../MenyInter/MenyTab1/GridContainer/ToplivoInventori/Label2"
onready var Toplivo: Control = $"../MenyInter/MenyTab1/GridContainer/ToplivoInventori"

onready var MagnitLabel: Control = $"../MenyInter/MenyTab2/ScrollContainer/GridContainer2/Magnit/Label2"
onready var Magnit: Control = $"../MenyInter/MenyTab2/ScrollContainer/GridContainer2/Magnit"

onready var GG = get_node("../../../../GG")

func _process(_delta):
	#Обновляем их
	golod()
	
	MetallInventoriLabel.text = str(G.metall)
	
	ComponentInventoriLabel.text = str(G.component)
	
	ElictronicInventoriLabel.text = str(G.electronic)
	
	ToplivoLabel.text = str(G.toplivo)
	
	MagnitLabel.text = str(G.magnit)
	
	EdaInventoriLabel.text = str(G.eda)
	
	DerevoInventoriLabel.text = str(G.derevo)
	
	if GG.sdorov > 0:
		$Bar/AnimatedSprite.animation = str(GG.sdorov)
	
	$ScrollContainer/HBoxContainer/Inventar/Label.text = str(round(G.SecInventori/4)) + " кг"
	
	PuliSAMLabel.text = str(G.puliSAM)
	
	PuliMGANLabel.text = str(G.puliMGAN)
	
	#Делаем проверку состояния
	if G.magnit <= 0:
		Magnit.hide()
	else:
		Magnit.show()
	
	if G.toplivo <= 0:
		Toplivo.hide()
	else:
		Toplivo.show()
	
	if G.minigan <= 0:
		MiniganInventori.hide()
	else:
		MiniganInventori.show()
	
	if G.magnitGan <= 0:
		MagnitGanInventori.hide()
	else:
		MagnitGanInventori.show()
	
	if G.snaper <= 0:
		SnapercaInventori.hide()
	else:
		SnapercaInventori.show()
	
	if G.djuns <= 0:
		DjunsInventori.hide()
	else:
		DjunsInventori.show()
	
	if G.tolstovca <= 0:
		TolstovcaInventori.hide()
	else:
		TolstovcaInventori.show()
	
	if G.samopal <= 0:
		SamopalInventori.hide()
	else:
		SamopalInventori.show()
	
	if G.puliMGAN <= 0:
		PuliMGan.hide()
	else:
		PuliMGan.show()
	
	if G.puliSAM <= 0:
		PuliSAM.hide()
	else:
		PuliSAM.show()
	
	if G.component <= 0:
		ComponentInventori.hide()
	else:
		ComponentInventori.show()
	
	if G.metall <= 0:
		MetallInventori.hide()
	else:
		MetallInventori.show()
	
	if G.electronic <= 0:
		ElictronicInventori.hide()
	else:
		ElictronicInventori.show()
	
	if G.derevo <= 0:
		DerevoInventori.hide()
	else:
		DerevoInventori.show()
	
	if G.eda <= 0:
		EdaInventori.hide()
	else:
		EdaInventori.show()

func golod():
	var gld = $"Bar/AnimatedSprite2"
	#gld.animation = "z<" + GG.golod
	if GG.golod <= 0:
		gld.animation = "z<0"
	elif GG.golod <= 2:
		gld.animation = "z<2"
	elif GG.golod <= 5:
		gld.animation = "z<5"
	elif GG.golod <= 8:
		gld.animation = "z<8"
	elif GG.golod <= 11:
		gld.animation = "z<11"
	elif GG.golod <= 14:
		gld.animation = "z<14"
	elif GG.golod <= 17:
		gld.animation = "z<17"
	elif GG.golod <= 20:
		gld.animation = "z<20"
