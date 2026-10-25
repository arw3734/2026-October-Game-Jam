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
var meows: int = 0
var mice_ate: int = 0

var is_hidden: bool = false
var nearby_hide_spot: Node2D = null
var current_hide_spot: Node2D = null

@onready var stamina_ticker = $StaminaTick
@onready var stamina_cooldown = $StaminaCooldown
@onready var stamina_recover = $StaminaRecover
@onready var quiet = $Quiet
func _ready():
	camera.enabled = true

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		if is_hidden:
			exit_hiding()
		elif is_instance_valid(nearby_hide_spot):
			enter_hiding(nearby_hide_spot)
	
	if is_hidden:
		velocity = Vector2.ZERO
		
		if stamina < 100 and stamina_recover.is_stopped():
			stamina_recover.start()
		return
	
	var sprinting = (
		Input.is_action_pressed("sprint")
		and stamina > 0
		and can_run
	)
	
	if Input.is_action_just_pressed("meow"):
		if not is_meowing:
			$Meow.play()
			meows+=1
			noise_area.scale = Vector2(7,7)
			state.increase_score(1, "[rainbow freq=1.0 sat=0.8 val=0.8 speed=1.0]Meowed![/rainbow]")
		is_meowing = true
		quiet.start()
	
	SPEED = 600.0 if sprinting else 300.0
	
	if sprinting:
		
		stamina_recover.stop()
		
		if (sprite.animation != "run"):
			$Sprite.play("run")
		if not is_meowing:
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

func set_nearby_hide_spot(spot: Node2D) -> void:
	nearby_hide_spot = spot

func clear_nearby_hide_spot(spot: Node2D) -> void:
	if nearby_hide_spot == spot:
		nearby_hide_spot = null


func enter_hiding(spot: Node2D) -> void:
	current_hide_spot = spot
	is_hidden = true
	sprite.hide()
	
	spot.bring_up()
	$PointLight2D.texture_scale = 3.0
	global_position = spot.hide_point.global_position
	velocity = Vector2.ZERO
	
	stamina_ticker.stop()
	ticking = false
	
	sprite.play("idle")


func exit_hiding() -> void:
	if not is_instance_valid(current_hide_spot):
		return
	
	global_position = current_hide_spot.exit_point.global_position
	sprite.show()
	
	current_hide_spot.bring_down()
	$PointLight2D.texture_scale = 10.0
	
	is_hidden = false
	current_hide_spot = null
	velocity = Vector2.ZERO


func _on_stamina_tick_timeout() -> void:
	stamina = max(stamina - tick_speed, 0)
	
	if stamina == 0:
		can_run = false
		stamina_cooldown.start()
	
	ticking = false

func _on_stamina_cooldown_timeout() -> void:
	can_run = true

func _on_stamina_recover_timeout() -> void:
	stamina = min(stamina + recover_speed, 100)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		if is_hidden:
			return
		
		var next_scene_packed = load("res://Scenes/end_screen.tscn")
		
		var next_scene = next_scene_packed.instantiate()
		
		next_scene.time_spent_store = state.time_ms
		next_scene.score = state.score
		next_scene.meows = meows
		next_scene.mice_ate = mice_ate
		get_tree().call_deferred("change_scene_to_node", next_scene)
		return
	
	if body.is_in_group("rats"):
		if is_hidden:
			return
		
		state.increase_score(5, "[shake rate=20.0 level=5 connected=1][color=red]Caught a rat![/color][/shake]")
		mice_ate+=1
		body.queue_free()
		$Crunch.play()

func _on_quiet_timeout() -> void:
	noise_area.scale = Vector2(1,1)
	is_meowing = false
