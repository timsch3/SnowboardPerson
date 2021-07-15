extends RigidBody2D

export var jumppower = -350
export var jumptorque = -1500
export var flippower = 800
export var stoppower = -5
export var leaningpower = 2
var speed: float
var random: float
var grounded = false
var crashed = false
var intro_message = false
var landsound_played = false
var bg_anim
var fini

func _ready():
	fini = false
	bg_anim = get_node("/root/Level1/Background/AnimationPlayer")
	bg_anim.seek(Data.daytime)
	$Sprite.play("default")
	if Data.checkpoint == 0:
		position = Vector2(-22039,-5504)
	if Data.checkpoint == 1:
		position = Vector2(-19020,-4907)
	if Data.checkpoint == 2:
		position = Vector2(-12800,-3096)
	if Data.checkpoint == 3:
		position = Vector2(-381,-1354)
		add_torque(-700)
	if Data.checkpoint == 4:
		position = Vector2(10656,-840)

func _physics_process(_delta):
	#INPUTS
	if Input.is_action_just_pressed("ui_cancel"):
		get_node("/root/Data/CanvasLayer/MessageSkip").hide()
		reset()
	if Input.is_action_just_pressed("leaderboard") and !Data.lb_shown:
			Data.lb_shown = true
	if Input.is_action_just_pressed("leaderboard") and Data.lb_shown:
			Data.lb_shown = false
	if !crashed and !Data.finished:
		if grounded:
			if Input.is_action_just_pressed("ui_accept"):
				apply_impulse(Vector2(0,20),Vector2(0,jumppower))
				$TorqueTimer.start()
				$Sprite.play("jumping")
				$AnimTimer.start()
				$Sounds/jump.pitch_scale = random
				$Sounds/jump.play(0)
			if Input.is_action_pressed("ui_left") and linear_velocity.x > 10:
				apply_impulse(Vector2(20,0),Vector2(stoppower,0))
				$Sprite.play("stopping")
			if Input.is_action_just_released("ui_left"):
				$Sprite.play("stopping", true)
				$AnimTimer.start()
			if Input.is_action_pressed("ui_right"):
				$Sprite.play("leaning")
				if linear_velocity.x > 200:
					apply_impulse(Vector2(-20,0),Vector2(leaningpower,0))
			if Input.is_action_just_released("ui_right"):
				$Sprite.play("default")
		if !grounded:
			if Input.is_action_pressed("ui_left"):
				apply_torque_impulse(-flippower)
			if Input.is_action_pressed("ui_right"):
				apply_torque_impulse(flippower)
	
	if crashed and Input.is_action_just_pressed("ui_accept"):
		if Data.checkpoint == 0:
			reset()
		else:
			get_node("/root/Data/CanvasLayer/MessageCheckpoint").hide()
			Data.daytime = bg_anim.get_current_animation_position()
			get_tree().reload_current_scene()
	
	if Data.finished:
		if grounded and linear_velocity.x > 10:
			apply_impulse(Vector2(20,0),Vector2(stoppower,0))
			if rotation_degrees < 10 and rotation_degrees > -10:
				$Sprite.play("stopping")
			else:
				$Sprite.play("default")
		if linear_velocity.x < 10 :
			$Sprite.play("cheering")
			fini = true
			
func _integrate_forces(state):
	if fini:
		var vel = state.get_linear_velocity ()
		state.set_linear_velocity (Vector2 (0, vel.y))
	
	speed = linear_velocity.x / 10
	Data.player_speed = speed

func _process(_delta):
	random = randf() + .5
	if grounded:
		if speed < 10 and speed:
			$Sounds/ride.volume_db = -80
		if speed > 10 and speed < 30:
			$Sounds/ride.pitch_scale = .1
			$Sounds/ride.volume_db = -3
		if speed > 30 and speed < 60:
			$Sounds/ride.pitch_scale = .15
			$Sounds/ride.volume_db = -3
		if speed > 60 and speed < 90:
			$Sounds/ride.pitch_scale = .2
			$Sounds/ride.volume_db = -3
		if speed > 90 and speed < 120:
			$Sounds/ride.pitch_scale = .25
			$Sounds/ride.volume_db = -3
		if speed > 120 and speed < 150:
			$Sounds/ride.pitch_scale = .3
			$Sounds/ride.volume_db = 0
		if speed > 150:
			$Sounds/ride.pitch_scale = .35
			$Sounds/ride.volume_db = -3
			

func reset():
	Data.daytime = 0
	Data.checkpoint = 0
	Data.timer.stop()
	get_node("/root/Data/CanvasLayer/VBox").hide()
	get_node("/root/Data/CanvasLayer/VBox2").hide()
	get_node("/root/Data/CanvasLayer/MessageCheckpoint").hide()
	get_node("/root/Data/CanvasLayer/MessageSkip").hide()
	Data.deciseconds = 0
	Data.crashes = 0
	Data.seconds = 0
	Data.minutes = 0
	Data.started = false
	Data.finished = false
	fini = false
	$Sprite.play("default")
	get_tree().reload_current_scene()

#PICKUPS
func icecream():
	if !crashed:
		apply_impulse(Vector2(-20,0),Vector2(100,0))
		$TorqueTimer.start()
		$Sounds/icecream.pitch_scale = random
		$Sounds/icecream.playing = true
func balloon():
	if !crashed:
		gravity_scale = 0
		apply_impulse(Vector2(0,20),Vector2(0,-100))
		$GravityTimer.start()
		$Sounds/balloon.pitch_scale = random
		$Sounds/balloon.playing = true

func _on_TorqueTimer_timeout():
	apply_torque_impulse(jumptorque)

func _on_GravityTimer_timeout():
	gravity_scale = 5

#CRASHING
func _on_RiderDetector_body_entered(body):
	if body.is_in_group("Ground") and !crashed and !Data.finished:
		crash()
func crash():
	$Sounds/fartel.pitch_scale = random
	$Sounds/fartel.playing = true
	$Sounds/land.pitch_scale = random
	$Sounds/land.playing = true
	linear_velocity = Vector2(-30,0)
	gravity_scale = 5
	crashed = true
	$Sprite.play("crashing")
	Data.crashed()
	if !Data.started:
		get_node("/root/Data/CanvasLayer/MessageCheckpoint").set_text(str("Press [Space]"))
	else:
		get_node("/root/Data/CanvasLayer/MessageCheckpoint").set_text(str("Press [Space] to return to the last checkpoint or [Esc] to start over"))
		Data.crashes += 1

#COLLISIONS
func _on_Player_body_entered(body):
	if !crashed:
		if body.is_in_group("Ground") and !grounded:
			$Sprite.play("jumping", true)
			$AnimTimer.start()
			$Sounds/ride.playing = true
			$LandSoundTimer.start()
			if !landsound_played:
				$Sounds/land.pitch_scale = random
				$Sounds/land.play(0)
				landsound_played = true
			grounded = true
		if body.is_in_group("Crash"):
			crash()

func _on_Player_body_exited(body):
	if !crashed:
		if grounded:
			if body.is_in_group("Ground"):
				$Sprite.play("flying")
				$Sounds/ride.playing = false
				grounded = false

func _on_AnimTimer_timeout():
	if !crashed:
		if grounded:
			$Sprite.play("default")
		if !grounded:
			$Sprite.play("flying")

func _on_LandSoundTimer_timeout():
	landsound_played = false
