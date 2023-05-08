extends Button

var catalog_name:String = ""
var node = null

func _pressed():
	if catalog_name != "" and node != null:
		node.dir_del_game(catalog_name)
