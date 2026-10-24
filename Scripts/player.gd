extends CharacterBody2D

const SPEED = 300.0
@export var sprite := AnimatedSprite2D
@export var camera:= Camera2D
var direction: Vector2

func _ready():
	camera.enabled = true

func _physics_process(delta: float) -> void:
	direction = Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("move_up", "move_down"))
	
	if direction.x > 0:
		sprite.flip_h = true
	elif direction.x < 0:
		sprite.flip_h = false
	
	
	if (direction.x || direction.y) and sprite.animation != "walk":
		$Sprite.play("walk")
	elif (!direction):
		$Sprite.play("idle")
	
	if direction.x:
		velocity.x = direction.x * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	
	if direction.y:
		velocity.y = direction.y * SPEED
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)
	
	
	move_and_slide()
