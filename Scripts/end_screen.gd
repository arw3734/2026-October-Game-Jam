extends Control

@export var score_label: Label
@export var time_spent_store_label: Label
@export var time_spent_hide_label: Label
@export var meows_label: Label
@export var mice_ate_label: Label

var score: int
var time_spent_store: int
var time_spent_hide: int
var meows: int
var mice_ate: int

func _ready():
	time_spent_store_label.text = "Lasted: " + str(time_spent_store)
	time_spent_hide_label.text = "Out of Hiding For: " + str(time_spent_hide)
	mice_ate_label.text = "Mice caught: " + str(mice_ate)
	meows_label.text = "Meows: " + str(meows)
	score_label.text = "Total Score: " + str(score)
	
func _on_button_pressed() -> void:
	var game = preload("res://Scenes/main_menu.tscn").instantiate();
	
	get_tree().change_scene_to_node(game)
