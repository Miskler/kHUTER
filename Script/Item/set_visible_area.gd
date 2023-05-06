extends Area2D

onready var g = get_node("/root/editmap")

func _ready():
	if g:
		return
	else:
		$ReferenceRect.editor_only = true
