extends Control
@export var time_label: Label
@export var state: Node
@export var stamina_bar: TextureProgressBar

@onready var player = get_parent()

@export var log_entries: VBoxContainer

@export var log_duration: float = 2.5
@export var fade_duration: float = 0.5
@export var max_log_entries: int = 6

func _ready():
	stamina_bar.value = 100
	
	state.connect("score_added", _on_score_added)

func _on_score_added(points: int, reason: String) -> void:
	var entry := $StoreCanvas/dup.duplicate()
	
	entry.text = "+%d  %s" % [points, reason]
		
	log_entries.add_child(entry)
	entry.show()
	
	while log_entries.get_child_count() > max_log_entries:
		var oldest = log_entries.get_child(0)
		log_entries.remove_child(oldest)
		oldest.queue_free()
	
	var tween = entry.create_tween()
	
	tween.tween_interval(log_duration)
	
	tween.tween_property(entry,"modulate:a",0.0,fade_duration)
	tween.tween_callback(entry.queue_free)

func _process(delta: float) -> void:
	time_label.text = state.current_time
	stamina_bar.value = player.stamina
