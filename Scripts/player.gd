extends CharacterBody2D

const recover_speed = 2
const tick_speed = 5

var SPEED = 300.0
@export var state: Node
@export var sprite: AnimatedSprite2D
@export var camera: Camera2D
@export var noise_area: Area2D
var direction: Vector2
var stamina = 100
var can_run: bool = true
var ticking: bool = false
var is_meowing: bool = false

@onready var stamina_ticker = $StaminaTick
@onready var stamina_cooldown = $StaminaCooldown
@onready var stamina_recover = $StaminaRecover
@onready var quiet = $Quiet
func _ready():
	camera.enabled = true

func _physics_process(delta: float) -> void:
	
	var sprinting = (
		Input.is_action_pressed("sprint")
		and stamina > 0
		and can_run
	)
	
	if Input.is_action_pressed("meow"):
		noise_area.scale = Vector2(5,5)
		$Meow.play()
		is_meowing = true
		state.increase_score(1, "Meowed!")
		quiet.start()
	
	SPEED = 600.0 if sprinting else 300.0
	
	if sprinting:
		
		stamina_recover.stop()
		
		if (sprite.animation != "run"):
			$Sprite.play("run")
		
		noise_area.scale = Vector2(1.5,1.5)
		if not ticking:
			stamina_ticker.start()
			ticking = true
		
	else:
		if not is_meowing:
			noise_area.scale = Vector2(1,1)
		stamina_ticker.stop()
		ticking = false
		
		if stamina < 100 and stamina_recover.is_stopped():
			stamina_recover.start()
	
	
	
	direction = Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("move_up", "move_down"))
	
	if direction.x > 0:
		sprite.flip_h = true
	elif direction.x < 0:
		sprite.flip_h = false
	
	
	if (direction.x || direction.y) and sprite.animation != "walk" and !sprinting:
		$Sprite.play("walk")
		if not sprinting and not is_meowing:
			noise_area.scale = Vector2(1,1)
	elif (!direction):
		if not is_meowing:
			noise_area.scale = Vector2(0.5,0.5)
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

func _on_stamina_tick_timeout() -> void:
	stamina = max(stamina - tick_speed, 0)
	
	if stamina == 0:
		can_run = false
		stamina_cooldown.start()
	
	ticking = false


func _on_stamina_cooldown_timeout() -> void:
	can_run = true


func _on_stamina_recover_timeout() -> void:
	if stamina < 100:
		stamina += recover_speed
	else:
		stamina = 100

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		# Lose code goes here
		pass
	
	if body.is_in_group("rats"):
		state.state.increase_score(5, "Caught a rat!")
		body.queue_free()
		$Crunch.play()


func _on_quiet_timeout() -> void:
	noise_area.scale = Vector2(1,1)
	is_meowing = false
