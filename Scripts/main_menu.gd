extends Control


func _on_play_pressed() -> void:
	var tutorial = preload("res://Scenes/tutorial.tscn").instantiate();
	
	get_tree().change_scene_to_node(tutorial)

func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_pet_button_pressed() -> void:
	$MeowBox.show()
	$PetButton/petTimer.start()
	$AudioStreamPlayer.play()


func _on_pet_timer_timeout() -> void:
	$MeowBox.hide()
