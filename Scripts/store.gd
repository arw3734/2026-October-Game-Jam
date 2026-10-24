extends Node2D



@onready var rat_region: NavigationRegion2D = $RatNavigationRegion

var rat_nav_map: RID

const RAT_SCENE = preload("res://rat.tscn")

func spawn_rat(position: Vector2) -> void:
	var rat = RAT_SCENE.instantiate()
	
	$Rats.add_child(rat)
	rat.global_position = position
	
	register_rat(rat)

func _ready() -> void:
	rat_nav_map = NavigationServer2D.map_create()
	NavigationServer2D.map_set_active(rat_nav_map, true)

	rat_region.set_navigation_map(rat_nav_map)

	for rat in get_tree().get_nodes_in_group("rats"):
		register_rat(rat)


func register_rat(rat: Node2D) -> void:
	var agent: NavigationAgent2D = (
		rat.get_node("NavigationAgent2D")
	)

	agent.set_navigation_map(rat_nav_map)


func _exit_tree() -> void:
	if rat_nav_map.is_valid():
		NavigationServer2D.free_rid(rat_nav_map)
