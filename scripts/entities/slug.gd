extends CharacterBody2D

@onready var SD = get_node("/root/rootGame/Node/SettingData")

var vec = Vector2()
var speed = Vector3(40, 560, 90)

var dead_mode = false
var stop = false

func _init():
	add_to_group("kritill_slime")

func _process(_delta):
	if stop == false and G.my_id() == $Sing.cur:
		if stop == false:
			$Anim.play("idle")
		elif vec.y < 0.0:
			if $Anim.animation != "jump":
				$Anim.play("jump")
		elif vec.y > 0.0:
			if $Anim.animation != "fall":
				$Anim.play("fall")
		elif dead_mode == true:
			$Anim.play("run")
		else:
			$Anim.play("walk")
		
		
		#printt($RayCast2D.is_colliding(), $RayCast2D2.is_colliding(), $RayCast2D3.is_colliding(), $RayCast2D4.is_colliding())
		if $Anim.flip_h == false and(($RayCast2D2.is_colliding() and $RayCast2D5.is_colliding()) or (dead_mode == false and not $RayCast2D4.is_colliding())):
			$Anim.flip_h = true
		elif $Anim.flip_h == true and(($RayCast2D.is_colliding() and $RayCast2D6.is_colliding()) or (dead_mode == false and not $RayCast2D3.is_colliding())):
			$Anim.flip_h = false
		
		if is_on_floor() and (($Anim.flip_h == true and($RayCast2D.is_colliding() and not $RayCast2D6.is_colliding())) or ($Anim.flip_h == false and($RayCast2D2.is_colliding() and not $RayCast2D5.is_colliding()))):
			vec.y = -speed.y
		
		if $Anim.flip_h == false:
			vec.x = speed.x
		else: vec.x = -speed.x
		
		if dead_mode == true:
			vec.x = vec.x * 8
			if is_on_floor(): 
				vec.y = -speed.y
		if not is_on_floor(): vec.y += speed.z
		
		
		if vec.y > 0.0 and is_on_floor() and not stop:
			$JumpUP.play()
		elif vec.y < 0.0 and is_on_floor() and not stop:
			$Jump.play()
		
		$Crawling.stream_paused = !is_on_floor() or int(vec.x) == 0 or stop
		
		
		set_velocity(vec)
		set_up_direction(Vector2(0, -1))
		move_and_slide()
		vec = velocity
		if get_tree().network_peer != null:
			get_node("/root/rootGame").rpc_unreliable("event_state", [$Anim.flip_h, global_position])

@rpc("any_peer") func event_state(dat):
	global_position = dat[1]
	$Anim.flip_h = dat[0]

@rpc("any_peer") func damage(_setting_bullet):
	if dead_mode == false:
		dead_mode = true
		$Sing.manager_signals.signal_event("damage", self)
		$BeforeExplosion.play()
		$Timer.connect("timeout", Callable(self, "bum"))
		$Timer.start()

func bum():
	stop = true
	$BeforeExplosion.stop()
	$Explosion.play()
	$TextureRect.hide()
	$AnimatedSprite2D.show()
	
	$AnimatedSprite2D.play("bum")
	
	$Node2D.rotation = 0
	
	for i in range(18):
		get_node("/root/rootGame").create_bullet([{"item": "mob"}, {}], [{"item": "mob"}, {}], $Node2D/Marker2D.global_position, $Node2D.rotation, "res://Texture2D/Other/Items/blebreskinproj.png", 90, 0, 1000, false)
		$Node2D.rotation_degrees += 20
	
	var name_ = "SlotInWorld_" + str(randf_range(0, 20))
	var count = int(randf_range(0, 5))
	if get_tree().network_peer == null or get_tree().is_server():
		spavn_lyt(count, name_)
		if get_tree().network_peer != null:
			rpc("spavn_lyt", count, name_)
	
	$Explosion.connect("finished", Callable(self, "del"))
	await $Anim.animation_finished
	$Anim.hide()

@rpc("any_peer") func spavn_lyt(count, name_):
	if count > 0:
		var random_item = load("res://scenes/entities/supporting/world_item.tscn").instantiate()
		
		random_item.name = name_
		
		random_item.get_node("SlotInWorld").significant_data = {"item": "explosive_crystal"}
		random_item.get_node("SlotInWorld").insignificant_data = {"uni_quantity": int(count)}
		
		random_item.global_position = global_position
		
		get_node("/root/rootGame/Node").add_child(random_item)

func del():
	Firebase.logEvent("npc_died", {"npc": {"value": "slime", "type": "string"}})
	queue_free()
