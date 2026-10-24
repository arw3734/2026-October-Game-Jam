extends CharacterBody2D


const SPEED = 300.0
const REPATH_INTERVAL: float = 0.2

@onready var state_machine = $StateMachine
@export var player := CharacterBody2D
@export var sprite := AnimatedSprite2D
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

var repath_timer: float = 0.0

func _ready() -> void:
	nav_agent.path_desired_distance = 12.0
	nav_agent.target_desired_distance = 20.0
	
func _physics_process(delta: float) -> void:
	
	if not state_machine.is_aggro() or not is_instance_valid(player):
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	if NavigationServer2D.map_get_iteration_id(nav_agent.get_navigation_map()) == 0:
		velocity = Vector2.ZERO
		return
	
	repath_timer -= delta
	
	if repath_timer <= 0.0:
		nav_agent.target_position = player.global_position
		repath_timer = REPATH_INTERVAL
	
	if nav_agent.is_navigation_finished():
		velocity = Vector2.ZERO
	else:
		var next_position: Vector2 = nav_agent.get_next_path_position()
		var direction: Vector2 = global_position.direction_to(next_position)
		velocity = direction * SPEED
		
		if direction.x > 0:
			sprite.flip_h = true
		elif direction.x < 0:
			sprite.flip_h = false
	
	move_and_slide()

func _on_area_body_entered(body: Node2D) -> void:
	if body == player:
		state_machine.swap_state("aggro")
		repath_timer = 0.0
	
