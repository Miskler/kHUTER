extends Button

export var event = {
	"sound": "res://Aydio/button.mp3", #Не обязательно
	"use_func": ["func", "param"], #EXIT - закрывает игру, OPEN scene - открывает сцену, SHOW node - активирует ноду
	"use_func2": ["func", "param"]
}

func _pressed():
	for i in event.keys():
		if i == "sound":
			$"/root/Menu/Details/ButtonSound".stream = load(event[i])
			$"/root/Menu/Details/ButtonSound".play()
		elif i in ["use_func", "use_fun2"]:
			if event[i][0] == "EXIT":
				EXIT()
			elif event[i][0] == "OPEN":
				OPEN(event[i][1])
			elif event[i][0] == "SHOW":
				SHOW(event[i][1])
			elif event[i][0] == "HIDE":
				HIDE(event[i][1])
			elif event[i][0] == "USE":
				if event[i].size() > 3:
					USE(event[i][1], event[i][2], event[i][3])
				else:
					USE(event[i][1], event[i][2])


func EXIT():
	get_tree().quit()

func USE(node_path, method, param = null):
	if get_node_or_null(node_path) != null:
		if param == null:
			get_node(node_path).call(method)
		else:
			get_node(node_path).call(method, param)

func OPEN(node_path):
	G.loadSCN = node_path
	$"/root/Menu/Animations".play("BlackScreen")

func SHOW(anim):
	$"/root/Menu/AnimationsMenedger".visible_p = anim

func HIDE(_anim):
	$"/root/Menu/AnimationsMenedger".visible_p = ""
