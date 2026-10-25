extends Node2D

@export var player: CharacterBody2D
@export var occlusion_tolerance: float = 60.0

const WALL_MASK = 1 << 1 

func has_line_of_sight(from_pos: Vector2, to_pos: Vector2) -> bool:
	var space = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(from_pos, to_pos, WALL_MASK)
	var result = space.intersect_ray(query)
	
	if result.is_empty():
		return true
	
	var distance_behind_wall = result.position.distance_to(to_pos)
	
	return distance_behind_wall < occlusion_tolerance

func _physics_process(_delta: float) -> void:
	for npc in get_tree().get_nodes_in_group("enemies"):
		var center = npc.global_position
		
		var visible = (
			has_line_of_sight(player.global_position, center)
			or has_line_of_sight(player.global_position, center + Vector2(-20, 0))
			or has_line_of_sight(player.global_position, center + Vector2(20, 0))
		)
		
		npc.visible = visible
