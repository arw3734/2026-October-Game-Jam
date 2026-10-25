extends Node

enum STATE {
	PASSIVE=0,
	AGGRO=1,
	SEARCHING=2
}

@export var sprite: AnimatedSprite2D
@export var aggro: Sprite2D
@export var lose_sight_delay: float = 1.0
@export var search_duration: float = 3.0

@onready var person: CharacterBody2D = get_parent()
@onready var nav_agent: NavigationAgent2D = $"../NavigationAgent2D"
@onready var detection_area: Area2D = $"../Area"

const WALL_MASK = 1 << 1
const REPATH_INTERVAL = 0.2

var current_state: int = STATE.PASSIVE

var player: CharacterBody2D
var patrol_points: Array[Marker2D] = []

var patrol_index: int = 0
var patrol_target_set: bool = false

@export_range(1, 6, 1) var patrol_max_step: int = 3
@export var nearby_guard_radius: float = 500.0
@export var patrol_target_spacing: float = 300.0

var patrol_direction: int = 1

var repath_timer: float = 0.0
var lost_sight_timer: float = 0.0
var search_timer: float = 0.0

var last_known_position: Vector2

func configure(player_ref: CharacterBody2D, patrol_route: Node2D) -> void:
	player = player_ref
	patrol_points.clear()
	if patrol_route != null:
		for child in patrol_route.get_children():
			if child is Marker2D:
				patrol_points.append(child as Marker2D)
	current_state = STATE.PASSIVE
	patrol_target_set = false
	
	patrol_direction = -1 if randf() < 0.5 else 1
	sprite.play("walk")

func swap_state(state_name: String):
	match state_name:
		"passive":
			if current_state == STATE.PASSIVE:
				return
			
			current_state = STATE.PASSIVE
			sprite.play("walk")
			
			patrol_target_set = false
		
		"aggro":
			if current_state == STATE.AGGRO:
				return
			
			current_state = STATE.AGGRO
			sprite.play("walk")
			aggro.show()
			$"../AudioStreamPlayer2D".play()
			
			repath_timer = 0.0
			lost_sight_timer = 0.0
			
			if is_instance_valid(player):
				last_known_position = player.global_position
				nav_agent.target_position = last_known_position
		
		"searching":
			if current_state == STATE.SEARCHING:
				return
			
			if person.velocity == Vector2.ZERO:
				sprite.play("idle")
			else:
				sprite.play("walk")
			
			current_state = STATE.SEARCHING
			search_timer = 0.0
			aggro.hide()
			
			nav_agent.target_position = last_known_position
			
			

func physics_update(delta: float):
	match current_state:
		STATE.PASSIVE:
			update_patrol()
		
		STATE.AGGRO:
			update_aggro(delta)
		
		STATE.SEARCHING:
			update_searching(delta)

func can_see_player() -> bool:
	if not is_instance_valid(player):
		return false
	if not detection_area.overlaps_body(player):
		return false
	
	var query = PhysicsRayQueryParameters2D.create(person.global_position, player.global_position, WALL_MASK)
	
	var hit = person.get_world_2d().direct_space_state.intersect_ray(query)
	
	return hit.is_empty()


func can_hear_player() -> bool:
	if not is_instance_valid(player):
		return false
	
	var noise_area: Area2D = player.get_node_or_null("NoiseArea")
	
	if noise_area == null:
		return false
	
	if player.velocity.length() < 10.0:
		return false
	
	return noise_area.overlaps_body(person)

func can_detect_player() -> bool:
	if not is_instance_valid(player):
		return false
	
	if player.get("is_hidden") == true:
		return false
	
	return can_see_player() or can_hear_player()
	
func update_patrol():
	if can_detect_player():
		swap_state("aggro")
		return
	
	if patrol_points.is_empty():
		return
	
	if not patrol_target_set:
		choose_nearest_patrol_target()
		return
	
	if nav_agent.is_navigation_finished():
		advance_patrol()


func choose_nearest_patrol_target() -> void:
	if patrol_points.is_empty():
		return
	
	var closest_index: int = 0
	var closest_distance: float = INF
	var available_index: int = -1
	var available_distance: float = INF
	
	for i in range(patrol_points.size()):
		var distance: float = person.global_position.distance_squared_to(patrol_points[i].global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest_index = i
		if not is_patrol_point_busy(i) and distance < available_distance:
			available_distance = distance
			available_index = i
	
	patrol_index = available_index if available_index != -1 else closest_index
	
	set_patrol_target()

func set_patrol_target():
	if patrol_points.is_empty():
		return
	
	nav_agent.target_position = patrol_points[patrol_index].global_position
	patrol_target_set = true


func advance_patrol() -> void:
	if patrol_points.size() <= 1:
		return
	
	var choices: Array[int] = []
	var max_step: int = mini(patrol_max_step, patrol_points.size() - 1)
	
	for step in range(1, max_step + 1):
		var index: int = posmod(patrol_index + patrol_direction * step, patrol_points.size())
		
		if not is_patrol_point_busy(index):
			choices.append(index)
	
	if choices.is_empty():
		patrol_index = posmod(patrol_index + patrol_direction, patrol_points.size())
	else:
		patrol_index = choices.pick_random()
	set_patrol_target()


func is_patrol_point_busy(index: int) -> bool:
	var target: Vector2 = patrol_points[index].global_position
	
	for other in get_tree().get_nodes_in_group("enemies"):
		var other_person := other as CharacterBody2D
		
		if other_person == null or other_person == person:
			continue
		
		if person.global_position.distance_squared_to(
			other_person.global_position
		) > nearby_guard_radius * nearby_guard_radius:
			continue
		
		var other_machine := other_person.get_node_or_null("StateMachine")
		var other_agent := other_person.get_node_or_null("NavigationAgent2D") as NavigationAgent2D
		
		if other_machine == null or other_agent == null:
			continue
		
		if other_machine.get("current_state") != STATE.PASSIVE:
			continue
		
		if not other_machine.get("patrol_target_set"):
			continue
		
		if target.distance_squared_to(
			other_agent.target_position
		) < patrol_target_spacing * patrol_target_spacing:
			return true
	
	return false


func update_aggro(delta: float):
	if can_detect_player():
		lost_sight_timer = 0.0
		last_known_position = player.global_position
		
		repath_timer -= delta
		
		if repath_timer <= 0.0:
			nav_agent.target_position = player.global_position
			repath_timer = REPATH_INTERVAL
	else:
		lost_sight_timer += delta
		
		if lost_sight_timer >= lose_sight_delay:
			swap_state("searching")

func update_searching(delta: float):
	if can_detect_player():
		swap_state("aggro")
		return
	
	if not nav_agent.is_navigation_finished():
		return
	
	search_timer += delta
	
	if search_timer >= search_duration:
		swap_state("passive")

func has_active_target() -> bool:
	match current_state:
		STATE.PASSIVE:
			return not patrol_points.is_empty()
		
		STATE.AGGRO:
			return is_instance_valid(player)
		
		STATE.SEARCHING:
			return true
	return false

func is_aggro():
	return current_state == STATE.AGGRO
