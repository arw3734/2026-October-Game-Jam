extends Node2D

@export var player: CharacterBody2D

const WALL_MASK = 1 << 1 

func has_line_of_sight(from_pos: Vector2,to_pos: Vector2) -> bool:
	var space = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(from_pos,to_pos,WALL_MASK)
	var result = space.intersect_ray(query)
	return result.is_empty()

func _physics_process(_delta: float) -> void:
	for npc in get_tree().get_nodes_in_group("enemies"):
		npc.visible = has_line_of_sight(player.global_position,npc.global_position)
