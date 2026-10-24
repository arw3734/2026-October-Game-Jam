extends Control


func _ready() -> void:
	pass

func _on_play_pressed() -> void:
	var game = preload("res://Scenes/store.tscn").instantiate();
	
	get_tree().change_scene_to_node(game)


func _on_exit_pressed() -> void:
	get_tree().quit()
