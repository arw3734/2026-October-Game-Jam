extends Control
@export var time_label:= Label
@export var state:= Node
@export var stamina_bar:= ProgressBar

@onready var player = get_parent()
func _ready():
	stamina_bar.value = 100

func _process(delta: float) -> void:
	time_label.text = state.current_time
	stamina_bar.value = player.stamina
