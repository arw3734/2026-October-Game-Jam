extends Node

enum STATE {
	PASSIVE=0,
	AGGRO=1
}

@export var sprite: AnimatedSprite2D
var current_state: int
var player_direction: Vector2

func swap_state(state_name: String):
	if state_name == "passive":
		current_state = STATE.PASSIVE
	elif state_name == "aggro":
		current_state = STATE.AGGRO

func _ready() -> void:
	current_state = STATE.PASSIVE

func _process(delta: float):
	if current_state == STATE.PASSIVE:
		sprite.play("idle")
	elif current_state == STATE.AGGRO:
		#chase code
		sprite.play("aggro")
	
	
