extends LineEdit

func text_changed(new_text):
	$"../../..".set_data(name, new_text)

func mouse_entered():
	$"../../..".set_description(name)
