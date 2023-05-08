extends Button

var catalog_name:String = ""
var node = null

func _pressed():
	node.dir_open(catalog_name)
