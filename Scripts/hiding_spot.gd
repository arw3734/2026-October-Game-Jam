extends StaticBody2D

@onready var hide_point: Marker2D = $HidePoint
@onready var exit_point: Marker2D = $ExitPoint
@onready var back_sprite: Sprite2D = $BackSprite
@onready var front_sprite: Sprite2D = $FrontSprite
@onready var occluder: LightOccluder2D = $LightOccluder2D

func bring_up():
	front_sprite.z_index = 1
	occluder.visible = false

func bring_down():
	front_sprite.z_index = 0
	occluder.visible = true

func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body.has_method("set_nearby_hide_spot"):
		body.call("set_nearby_hide_spot", self)

func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body.has_method("clear_nearby_hide_spot"):
		body.call("clear_nearby_hide_spot", self)
