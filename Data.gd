extends Node

export var checkpoint = -1
export var started = false
export var finished = false

var player_speed
var timer
var topspeed = 0
var crashes = 0
var deciseconds: int = 0
var total_deciseconds: int = 0
var seconds: int = 0
var minutes: int = 0
var daytime: int = 0
var username = "Player"
var lb_shown = false
var url: String

func _ready():
	$CanvasLayer/MessageCheckpoint.hide()
	$CanvasLayer/MessageSkip.show()
	get_node("/root/Level1/Player").mode = 1
	$SkipTimer.start()
	$Music.playing = true
	$CanvasLayer/VBox.hide()
	$CanvasLayer/VBox2.hide()
	timer = Timer.new()
	timer.connect("timeout",self,"_on_timer_timeout") 
	timer.set_wait_time(.1)
	timer.set_one_shot(false)
	add_child(timer)

func crashed():
	$CanvasLayer/MessageCheckpoint.show()

func _on_timer_timeout():
	deciseconds += 1
	total_deciseconds += 1
	if deciseconds == 10:
		deciseconds = 0
		seconds += 1
	if seconds == 60:
		seconds = 0
		minutes += 1
	if minutes == 60:
		minutes  = 0

func _process(_delta):
	var time_left = $SkipTimer.get_time_left() + 1
	
	$CanvasLayer/MessageSkip.set_text(str("Press [ESC] to skip the intro\n\nStarting in ", str(time_left).pad_decimals(0)))
	if started:
		var ts = player_speed
		if ts > topspeed:
			topspeed = ts
		$CanvasLayer/VBox/Speed.set_text(str("Speed: ", str(player_speed).pad_decimals(0)))
		$CanvasLayer/VBox/Time.set_text(str("Time: ", str(minutes), ":", str(seconds).pad_zeros(2), ":", str(deciseconds)))
		$CanvasLayer/VBox.show()
	if finished:
		$CanvasLayer/VBox2/Speed.set_text(str("Your top speed: ", str(topspeed).pad_decimals(0)))
		$CanvasLayer/VBox2/Time.set_text(str("Your total time: ", str(minutes), ":", str(seconds).pad_zeros(2), ":", str(deciseconds)))
		$CanvasLayer/VBox2/Crashes.set_text(str("Your total crashes: ", str(crashes)))
		$CanvasLayer/VBox.hide()
		$CanvasLayer/VBox2.show()

func _on_button_toggled(button_pressed):
	if button_pressed:
		$Music.playing = true
	if !button_pressed:
		$Music.playing = false

func _on_SkipTimer_timeout():
	$CanvasLayer/MessageSkip.hide()
	get_node("/root/Level1/Player").mode = 0
