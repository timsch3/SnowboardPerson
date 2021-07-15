extends Node

var leaderboard: String

func add(url):
	$HTTPRequest.request(str(url))

func get_lb():
	var content = File.new()
	content = $HTTPRequest.request("http://dreamlo.com/lb/5ec7ac58377dce0a1423173c/xml")
	print()

func _on_button_toggled(button_pressed):
	if button_pressed:
		$CanvasLayer/RichTextLabel.show()
		get_lb()
	if !button_pressed:
		$CanvasLayer/RichTextLabel.hide()
