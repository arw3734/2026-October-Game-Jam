extends CharacterBody2D

@export var player: CharacterBody2D
@export var sprite: AnimatedSprite2D
@export var patrol_route: Node2D

@export var patrol_speed: float = 120.0
@export var chase_speed: float = 400.0

@onready var state_machine = $StateMachine
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

func _ready() -> void:
	state_machine.configure(player, patrol_route)

func _physics_process(delta: float) -> void:
	
	if NavigationServer2D.map_get_iteration_id(nav_agent.get_navigation_map()) == 0:
		velocity = Vector2.ZERO
		return
	
	state_machine.physics_update(delta)
	
	if not state_machine.has_active_target():
		velocity = Vector2.ZERO
	else:
		var next_position = nav_agent.get_next_path_position()
		
		if nav_agent.is_navigation_finished():
			velocity = Vector2.ZERO
		else:
			var direction = global_position.direction_to(next_position)
			
			var speed = chase_speed if state_machine.is_aggro() else patrol_speed
			velocity = direction * speed
			
			if direction.x > 0:
				sprite.flip_h = true
			elif direction.x < 0:
				sprite.flip_h = false
	
	move_and_slide()
