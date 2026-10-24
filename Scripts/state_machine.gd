extends Node

enum STATE {
	PASSIVE=0,
	AGGRO=1,
	SEARCHING=2
}

@export var sprite: AnimatedSprite2D
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
	sprite.play("idle")

func swap_state(state_name: String):
	match state_name:
		"passive":
			if current_state == STATE.PASSIVE:
				return
			
			current_state = STATE.PASSIVE
			sprite.play("idle")
			
			patrol_target_set = false
		
		"aggro":
			if current_state == STATE.AGGRO:
				return
			
			current_state = STATE.AGGRO
			sprite.play("aggro")
			
			repath_timer = 0.0
			lost_sight_timer = 0.0
			
			if is_instance_valid(player):
				last_known_position = player.global_position
				nav_agent.target_position = last_known_position
		
		"searching":
			if current_state == STATE.SEARCHING:
				return
			
			current_state = STATE.SEARCHING
			search_timer = 0.0
			
			nav_agent.target_position = last_known_position
			
			sprite.play("idle")

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

func update_patrol():
	if can_see_player():
		swap_state("aggro")
		return
	
	if patrol_points.is_empty():
		return
	
	if not patrol_target_set:
		set_patrol_target()
		return
	
	if nav_agent.is_navigation_finished():
		advance_patrol()

func set_patrol_target():
	if patrol_points.is_empty():
		return
	
	nav_agent.target_position = patrol_points[patrol_index].global_position
	
	patrol_target_set = true

func advance_patrol():
	patrol_index = (patrol_index + 1) % patrol_points.size()
	set_patrol_target()

func update_aggro(delta: float):
	if can_see_player():
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
	if can_see_player():
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
