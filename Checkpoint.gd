extends Area2D

func fade():
	$Timer.start()

func _on_Timer_timeout():
	queue_free()
