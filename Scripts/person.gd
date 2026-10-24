extends CharacterBody2D

@onready var state_machine = $StateMachine
const SPEED = 300.0
@export var player := CharacterBody2D
@export var sprite := AnimatedSprite2D
@onready var direction = Vector2(0,0)

func _physics_process(delta: float) -> void:
	if direction.x > 0:
		sprite.flip_h = true
	elif direction.x < 0:
		sprite.flip_h = false
	
	if direction.x:
		velocity.x = direction.x * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if direction.y:
		velocity.y = direction.y * SPEED
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)
	
	move_and_slide()

func _on_area_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		state_machine.swap_state("aggro")
	
