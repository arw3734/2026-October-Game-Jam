extends CharacterBody2D

var SPEED = 300.0
@export var sprite := AnimatedSprite2D
@export var camera:= Camera2D
var direction: Vector2
var stamina = 100
var can_run: bool = true
var ticking: bool = false

@onready var stamina_ticker = $StaminaTick
@onready var stamina_cooldown = $StaminaCooldown
@onready var stamina_recover = $StaminaRecover
func _ready():
	camera.enabled = true

func _physics_process(delta: float) -> void:
	
	var sprinting = (
		Input.is_action_pressed("sprint")
		and stamina > 0
		and can_run
	)
	
	SPEED = 450.0 if sprinting else 300.0
	
	if sprinting:
		stamina_recover.stop()
		
		if not ticking:
			stamina_ticker.start()
			ticking = true
		
	else:
		stamina_ticker.stop()
		ticking = false
		
		if stamina < 100 and stamina_recover.is_stopped():
			stamina_recover.start()
	
	
	
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

func _on_stamina_tick_timeout() -> void:
	stamina = max(stamina - 1, 0)
	
	if stamina == 0:
		can_run = false
		stamina_cooldown.start()
	
	ticking = false


func _on_stamina_cooldown_timeout() -> void:
	can_run = true


func _on_stamina_recover_timeout() -> void:
	if stamina < 100:
		stamina += 1
