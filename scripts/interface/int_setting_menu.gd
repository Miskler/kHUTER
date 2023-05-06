extends SpinBox

func mouse_entered():
	$"../../..".set_description(name)

func changed(val):
	$"../../..".set_data(name, val)
