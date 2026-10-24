extends Control


func _on_play_pressed() -> void:
	var game = preload("res://Scenes/store.tscn").instantiate();
	
	get_tree().change_scene_to_node(game)


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_pet_button_pressed() -> void:
	$MeowBox.show()
	$PetButton/petTimer.start()
	print("a")


func _on_pet_timer_timeout() -> void:
	$MeowBox.hide()
