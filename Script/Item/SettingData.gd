extends Node

export var map_settings = {
	"can_be_saved": true,
	"edit_save": false,
	"is_save": false,
	"creation_position": Vector2(0, 0),
	"specter": false,
	"revive": true,
	"taking_away_hunger": 12, #Значение меньше нуля отключает функцию
	"dehumidification_frequency": 12, #Значение меньше нуля отключает функцию
	"number_of_clutches": 3,
	"adding_to_statistics": true, #Разрешение элементам карты вносить новые данные в статистику
	"crafting": ["breaker", "remotedrill", "standart_bullet", "flask"],
	"time_to_destruction": 60,
}

var multiplayer_settings = {
	"password": null, #Если null - пароля нет
	"whitelist": [], #Вводим никнеймы, пуст значит отключен
	"banned": [], #Баны приоритетней белого списка
	"open_server": true, #Разрешение на открытие сервера
	"save_server": true, #Разрешает пользователям сохранять игру, can_be_saved - только для сервера
}

onready var items = ["diskette"]

export var transition_value = {
	"ground": 2,
	"stone": 4,
	"wall": 3,
	"component": 3,
	"sraft": 2,
	"metal": 3,
	"copper_stick": 3,
	"water": 1,
}

export var use_tile = {
	"craft": {"use_func": ["/root/rootGame/Node/Player", "show_craft_menu"]},
	"water": {"add_item": "water"},
}

func _ready():
	items = []
	var list = $ItemData.get_script().get_script_property_list()
	for i in range(list.size()):
		print(list[i])
		$ItemData.get(list[i]["name"])["item"] = list[i]["name"]
		items.append(list[i]["name"])
	
	print("items: ", items)
