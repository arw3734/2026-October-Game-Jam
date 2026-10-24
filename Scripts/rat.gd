extends CharacterBody2D

@export var run_speed: float = 550.0
@export var acceleration: float = 4000.0

@export var min_target_distance: float = 350.0
@export var min_turn_interval: float = 1.5
@export var max_turn_interval: float = 3.0
@export_range(0.0, 1.0) var turn_chance: float = 0.65

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var sprite: Sprite2D = $Sprite

var turn_timer: float = 0.0



func _ready() -> void:
	nav_agent.path_desired_distance = 24.0
	nav_agent.target_desired_distance = 28.0
	
	await get_tree().physics_frame
	
	pick_new_destination()

func _physics_process(delta: float) -> void:
	if NavigationServer2D.map_get_iteration_id(nav_agent.get_navigation_map()) == 0:
		return
	
	turn_timer -= delta
	
	if nav_agent.is_navigation_finished():
		pick_new_destination()
	elif turn_timer <= 0.0:
		if randf() < turn_chance:
			pick_new_destination()
		else:
			reset_turn_timer()
	
	if nav_agent.is_navigation_finished():
		velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
	else: 
		var next_pos = nav_agent.get_next_path_position()
		
		var direction = global_position.direction_to(next_pos)
		
		velocity = velocity.move_toward(direction * run_speed, acceleration * delta)
	
	if abs(velocity.x) > 10.0:
		sprite.flip_h = velocity.x < 0.0
	move_and_slide()

func pick_new_destination():
	var nav_map = nav_agent.get_navigation_map()
	
	if NavigationServer2D.map_get_iteration_id(nav_map) == 0:
		return
	
	var best_point = global_position
	var best_distance = 0.0
	
	for i in range(15):
		var point = NavigationServer2D.map_get_random_point(nav_map, nav_agent.navigation_layers, true)
		
		var distance = global_position.distance_to(point)
		
		if distance > best_distance:
			best_distance = distance
			best_point = point
		
		if distance >= min_target_distance:
			break
	
	if best_distance > 50.0:
		nav_agent.target_position = best_point
	
	reset_turn_timer()

func reset_turn_timer():
	turn_timer = randf_range(min_turn_interval, max_turn_interval)
