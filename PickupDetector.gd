extends Area2D

onready var sprite = get_node("../Sprite")
onready var player = get_node("../../Player")
onready var sound_cp = get_node("../../Player/Sounds/checkpoint")
onready var sound_sf = get_node("../../Player/Sounds/startfinish")

func _on_PickupDetector_area_shape_entered(_area_id, area, _area_shape, _self_shape):
	if area.is_in_group("Icecream"):
		player.icecream()
		area.queue_free()
	if area.is_in_group("Balloon"):
		player.balloon()
		area.queue_free()
	if area.name == "CheckpointZero" and !player.crashed:
		player.linear_velocity = Vector2(0,0)
	if area.name == "Checkpoint00" and !player.crashed:
		Data.checkpoint = 0
		area.get_node("AnimationPlayer").play("saved")
		area.fade()
		sound_cp.pitch_scale = .8
		sound_cp.playing = true
	if area.name == "Checkpoint01" and !player.crashed:
		Data.checkpoint = 1
		area.get_node("AnimationPlayer").play("saved")
		area.fade()
		sound_cp.pitch_scale = .9
		sound_cp.playing = true
	if area.name == "Checkpoint02" and !player.crashed:
		Data.checkpoint = 2
		area.get_node("AnimationPlayer").play("saved")
		area.fade()
		sound_cp.pitch_scale = 1
		sound_cp.playing = true
	if area.name == "Checkpoint03" and !player.crashed:
		Data.checkpoint = 3
		area.get_node("AnimationPlayer").play("saved")
		area.fade()
		sound_cp.pitch_scale = 1.1
		sound_cp.playing = true
	if area.name == "Checkpoint04" and !player.crashed:
		Data.checkpoint = 4
		area.get_node("AnimationPlayer").play("saved")
		area.fade()
		sound_cp.pitch_scale = 1.2
		sound_cp.playing = true

func _on_Start_area_entered(_area):
	if !player.crashed:
		sound_sf.playing = true
		Data.timer.start()
		Data.started = true

func _on_Finish_area_entered(_area):
	if !player.crashed:
		sound_sf.playing = true
		Data.timer.stop()
		Data.finished = true
