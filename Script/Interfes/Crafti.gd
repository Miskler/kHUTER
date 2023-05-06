extends Control

func _process(_delta):
	
	if G.electronic >= 2 and G.component >= 1 and G.magnitGan >= 1:
		$ScrollContainer/VBoxContainer/magnitBull.show()
	else:
		$ScrollContainer/VBoxContainer/magnitBull.hide()
	
	if G.metall >= 6 and G.electronic >= 9 and G.component >= 3 and G.magnitGan <= 0:
		$ScrollContainer/VBoxContainer/magnitca.show()
	else:
		$ScrollContainer/VBoxContainer/magnitca.hide()
	
	if G.metall >= 1 and G.derevo >= 3 and G.samopal >= 0:
		$ScrollContainer/VBoxContainer/GovnoGan.show()
	else:
		$ScrollContainer/VBoxContainer/GovnoGan.hide()
	
	if G.metall >= 1 and(G.samopal >= 1 or G.snaper >= 1):
		$ScrollContainer/VBoxContainer/PuliSAM.show()
	else:
		$ScrollContainer/VBoxContainer/PuliSAM.hide()
	
	if G.metall >= 4 and G.electronic >= 5 and G.minigan <= 0:
		$ScrollContainer/VBoxContainer/MiniGan.show()
	else:
		$ScrollContainer/VBoxContainer/MiniGan.hide()
	
	if G.derevo >= 2 and G.minigan >= 1:
		$ScrollContainer/VBoxContainer/PuliM.show()
	else:
		$ScrollContainer/VBoxContainer/PuliM.hide()
	
	if G.metall >= 7 and G.component >= 5 and G.snaper <= 0:
		$ScrollContainer/VBoxContainer/Snaperca.show()
	else:
		$ScrollContainer/VBoxContainer/Snaperca.hide()

func pressed_govno():
	G.metall -= 1
	G.derevo -= 3
	G.samopal += 1
	G.peresot()

func pressed_pulaSAM():
	G.metall -= 1
	G.puliSAM += 1
	G.peresot()

func pressed_minigan():
	G.metall -= 4
	G.electronic -= 5
	G.minigan += 1
	G.peresot()

func pressed_puliMGAN():
	G.derevo -= 2
	G.puliMGAN += 5
	G.peresot()

func pressed_snaperca():
	G.metall -= 7
	G.component -= 5
	G.snaper += 1
	G.peresot()

func pressed_craft_magnitca():
	G.metall -= 6
	G.electronic -= 9
	G.component -= 3
	G.magnitGan += 1

func pressed_magniti():
	G.component -= 1
	G.electronic -= 2
	G.magnit += 3
