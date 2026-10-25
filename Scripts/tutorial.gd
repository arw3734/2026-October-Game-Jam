extends Control



func _on_button_pressed() -> void:
	var game = preload("res://Scenes/store.tscn").instantiate();
	
	get_tree().change_scene_to_node(game)
