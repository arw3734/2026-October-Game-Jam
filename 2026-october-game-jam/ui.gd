extends Control
@export var time_label:= Label
@export var state:= Node

func _process(delta: float) -> void:
	time_label.text = state.current_time
