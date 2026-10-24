extends Node


var current_time: String
var time_ms: int
var minutes: String
var hours: int

func _ready() -> void:
	hours = 0
	minutes = "00"
	time_ms = 0
	current_time = "12:00"

func _on_time_timeout() -> void:
	time_ms+=1
	
	if time_ms % 75 > 75/2:
		minutes = "30"
	else:
		minutes = "00"
	
	if time_ms % 75 == 0:
		hours += 1
	
	if time_ms < 75:
		current_time = "12" + ":" + minutes
	else:
		current_time = str(hours) + ":" + minutes
	
