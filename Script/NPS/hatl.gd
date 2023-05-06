extends KinematicBody2D

export var vohol = false
export var vec = Vector2()
export var sover = true
export var avtopilot = false
var glPosit
var menPos
var posit

export var g = 1 #Голод
export var s = 1 #Здоровье
export var b = 0.1 #Бодрость

export var game = false

export var vihe = -18
export var potrebVihe = 0.1

export var peredves = 0

export var nise = 5
export var potrebNise = 0.05

export var bok = 7
export var potrebBok = 0.07

export var bensin = 600

export var rot = 0.0

func _ready():
	if get_node("/root/editmap"):
		return
	else:
		game = true
		$CollisionShape2D.disabled = false
		$KinematicBody2D/CollisionShape2D2.disabled = false
		$SdorovHp.wait_time = get_node("/root/rootGame/Node/SettingData").taking_away_hunger
		$SleepEvent.wait_time = get_node("/root/rootGame/Node/SettingData").fatigue_frequency
	
	if G.grafLoy == true:
		$AnimatedSprite2/ColorRect.hide()
		$AnimatedSprite2/AnimatedSprite.show()
		$AnimatedSprite2/AnimatedSprite.playing = true

func _physics_process(_delta):
	if game == false:
		return
	
	get_node("Camera2D/CanvasLayer/blur").material.set_shader_param("a", b)
	
	if s <= 0 or b > 2.0:
		var ggG = gg.instance()
		ggG.position = $Position2D.global_position
		ggG.golod = g
		ggG.sdorov = s
		get_parent().add_child(ggG)
		vohol = false
		return
	
	if is_on_floor() == true:
		peredves = 0
		vec = 0
		print("ggg" + str(-peredves))
	
	rotation_degrees = rot
	
	if peredves >= 20:
		peredves = 20
	elif peredves <= -20:
		peredves = -20
	
	$".".move_local_y(-peredves)
	
	if bensin < 30:
		$Camera2D/CanvasLayer/Control3/Control.show()
	else:
		$Camera2D/CanvasLayer/Control3/Control.hide()
	
	if $Camera2D/CanvasLayer/Control3/Control/TextureButton.pressed:
		var ll
		ll = 100 - bensin
		print(ll)
		if ll > 0 and ll <= G.toplivo:
			G.toplivo = G.toplivo - ll
			bensin = bensin + ll
	
	if avtopilot == true:
		
		if bensin <= 0:
			avtopilot = false
		
		if rot > 0 and bensin > 0:
			rot = rot - 0.5
			bensin -= potrebBok
		elif rot < 0 and bensin > 0:
			rot = rot + 0.5
			bensin -= potrebBok
		
		get_node("Camera2D/CanvasLayer/Control2/Label").text = "автопилот: включен"
		if $".".global_position.y > menPos:
			$AnimatedSprite2.show()
			peredves = peredves + (0.6)
			bensin = bensin - potrebVihe
		else:
			if not Input.is_action_pressed("w"):
				$AnimatedSprite2.hide()
	else:
		get_node("Camera2D/CanvasLayer/Control2/Label").text = "автопилот: выключен"
	
	if vohol == true:
		$Light2D.show()
		$Camera2D/CanvasLayer/Control.show()
		$Camera2D/CanvasLayer/Control2.show()
		$Camera2D/CanvasLayer/Control3.show()
		get_node("Camera2D/CanvasLayer/Control/Label").text = "Топливо: " + str(round(bensin))
		
		$AnimatedSprite.play("sacrit")
		$KinematicBody2D/CollisionShape2D2.disabled = true
		
		if Input.is_action_pressed("w") and bensin > 0:
			if peredves < 100:
				peredves = peredves + 1
				bensin = bensin - potrebVihe
				$AnimatedSprite2.show()
			reform()
		elif Input.is_action_pressed("s") and not is_on_ceiling() and bensin > 0:
			if peredves < 100:
				peredves = peredves - 1
				bensin = bensin - potrebNise
			if avtopilot == false:
				$AnimatedSprite2.hide()
			reform()
		else:
			if avtopilot == false:
				$AnimatedSprite2.hide()
		
		if Input.is_action_pressed("d") and bensin > 0:
			rot = rot + 1
			bensin = bensin - potrebBok
			if !Input.is_action_pressed("w") and peredves > 0:
				peredves = peredves - 0.2
			reform()
		elif Input.is_action_pressed("a") and bensin > 0:
			rot = rot - 1
			bensin = bensin - potrebBok
			if !Input.is_action_pressed("w") and peredves > 0:
				peredves = peredves - 0.2
			reform()
	
	else:
		
		$Light2D.hide()
		$Camera2D/CanvasLayer/Control.hide()
		$Camera2D/CanvasLayer/Control2.hide()
		$Camera2D/CanvasLayer/Control3.hide()
		$AnimatedSprite.play("otcrit")
		$KinematicBody2D/CollisionShape2D2.disabled = false
		
	
	if !Input.is_action_pressed("w") and !Input.is_action_pressed("a") and !Input.is_action_pressed("d") and avtopilot == false and(is_on_ceiling() or is_on_floor() or is_on_wall()):
		if rot < 0 and rot > -16:
			rot += 0.5
		elif rot > 0 and rot < 16:
			rot -= 0.5
		
		elif rot > 16 and rot < 89:
			rot += 1
		elif rot < -16 and rot > -89:
			rot -= 1
		
		elif rot > 16 and rot >= 90:
			rot -= 1
		elif rot < -16 and rot <= -90:
			rot += 1
	
	if rot >= 360:
		rot -= 360
	elif rot <= -360:
		rot += 360
	
	if !is_on_ceiling() and !is_on_floor() and !is_on_wall() and !Input.is_action_pressed("w"):
		vec.y = vec.y + 5
	elif !Input.is_action_pressed("w"):
		
		vec.y = 0
		if peredves > 2:
			peredves = peredves - 1
		elif peredves < -2:
			peredves = peredves + 1
		else:
			peredves = 0
	
	if peredves >= 1:
		peredves = peredves - 0.3
	
	if vec.y > 500:
		vec.y = 500
	elif vec.y < -500:
		vec.y = -500
	
	vec = move_and_slide(vec)

var gg = load("res://Sceni/NPS/Player.res")

func _input(_event):
	if vohol == true and sover == true:
		if Input.is_action_just_pressed("Use") or s <= 0:
			var ggG = gg.instance()
			ggG.position = $Position2D.global_position
			ggG.golod = g
			ggG.sdorov = s
			get_parent().add_child(ggG)
			vohol = false
	
	if Input.is_action_just_pressed("OpenInvetori"):
		avtopilot = not avtopilot
		reform()

func use_b(user, sdorov, golod, sleep):
	if vohol == false:
		
		b = sleep
		g = golod
		s = sdorov
		
		sover = false
		$Timer.start()
		user.sahod_hatl(self)
		vohol = true
		$Camera2D.current = true
		get_tree().paused = false

func _on_Timer_timeout():
	sover = true

func reform():
	if avtopilot == true:
		glPosit = $".".global_position.y
	else:
		glPosit = 0
	
	menPos = glPosit + 5
	
	if avtopilot == true:
		glPosit = $".".global_position.x
	else:
		glPosit = 0
	
	posit = glPosit

func SdorovHp_timeout():
	if g > 0 and s > 0:
		g = g - 1
		if g >= 11 and s <= 4:
			s = s + 1
			g = g - 1
	elif g <= 0 and s >= 1:
		s = s - 1
	else:
		g = 0
		s = 0

func SleepEvent():
	b += 0.1
