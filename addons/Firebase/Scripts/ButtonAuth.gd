@tool
extends Button
#class_name ButtonAuth, "res://addons/Firebase/Resources/sign-in4.png"
#class_name ButtonAuth, "res://addons/Firebase/Resources/Firebase.png"

@export var type = Firebase.signInButtonType.FirebaseUI: set = setType
@export var texture: Texture2D = load("res://addons/Firebase/Resources/Google.png"): set = setTexture
@export var colorButton: Color = Color("ecebf0"): set = setColorButton
@export var arrayColorButton: Dictionary = {"Google":Color("ecebf0"), "GitHub":Color("262c3b"), "FirebaseUI":Color("262c3b")}
@export var colorText: Color = Color("000000"): set = setColorText
@export var arrayColorText: Dictionary = {"Google":Color("000000"), "GitHub":Color("ffffff"), "FirebaseUI":Color("ffffff")}
@export var arrayText: Dictionary = {"Google": "Sign In Google", "GitHub": "Sing In GitHub", "FirebaseUI":"Sign In"}

func _enter_tree():
#	disabled = true
	custom_minimum_size[1] = 50
	mouse_default_cursor_shape = CURSOR_POINTING_HAND
	
	var styleNormal = StyleBoxFlat.new()
	set("theme_override_styles/normal", styleNormal) 
	set("theme_override_styles/focus", StyleBoxEmpty.new())
	set("theme_override_styles/pressed", styleNormal)
	set("theme_override_styles/hover", styleNormal)
	
	
	var borderRadius = 8
	get("theme_override_styles/normal").set("corner_radius_top_left", borderRadius)
	get("theme_override_styles/normal").set("corner_radius_top_right", borderRadius)
	get("theme_override_styles/normal").set("corner_radius_bottom_right", borderRadius)
	get("theme_override_styles/normal").set("corner_radius_bottom_left", borderRadius)
	
	if !has_node("ButtonAuthContent"):
		add_child(load("res://addons/Firebase/UI/ButtonAuthContent.tscn").instantiate())
		connect("pressed", Callable(self, "_on_ButtonAuth_pressed"))
		Firebase.connect("getCurrentUserSignal", Callable(self, "on_getCurrentUserSignal"))
	
	setType(type)
	checkDisable()

func on_getCurrentUserSignal():
	checkDisable()

func checkDisable():
	var _type = Firebase.signInButtonType.keys()[type]
	if !Engine.has_singleton("AFirebase"): 
		disabled = true
		print("ButtonAuth.checkDisable() !Engine.has_singleton('AFirebase')")
		return
	if Firebase.firebase == null: 
		print("Firebase ButtonAuth %s init, Firebase.firebase == null"%[_type])
		disabled = true
		return
	if Firebase.firebaseUser.isNull == null:
		print("Firebase ButtonAuth %s init, Firebase.firebaseUser.isNull == null (need call Firebase.getCurrentUser())"%[_type])
		disabled = true
		return
	if Firebase.firebaseUser.isNull == false:
		print("Firebase ButtonAuth %s init, Firebase.firebaseUser.isNull != null (user logged)"%[_type])
		disabled = true
		return
	disabled = false

func setType(new):
	type = new
	var _type = Firebase.signInButtonType.keys()[type]
	
	setTexture(load("res://addons/Firebase/Resources/%s.png"%[_type]))
	setColorText(arrayColorText["%s"%[_type]])
#	print(_type)
	setColorButton(arrayColorButton["%s"%[_type]])
	setText(arrayText["%s"%[_type]])

func setText(new):
	if !has_node("ButtonAuthContent/HBoxContainer/Label"): return
	$ButtonAuthContent/HBoxContainer/Label.text = new

func setColorText(new):
	colorText = new
	if !has_node("ButtonAuthContent/HBoxContainer/Label"):return
	$ButtonAuthContent/HBoxContainer/Label.set("theme_override_colors/font_color", new)

func setColorButton(new):
	colorButton = new
	if get("theme_override_styles/normal") == null: return
	get("theme_override_styles/normal").bg_color = colorButton

func setTexture(new):
	texture = new
	if !has_node("ButtonAuthContent/HBoxContainer/TextureRect"):return
	$ButtonAuthContent/HBoxContainer/TextureRect.texture = texture


func _on_ButtonAuth_pressed(): 
#	print("Firebase ButtonAuth _on_ButtonAuth_pressed")

	Firebase.auth(type)
