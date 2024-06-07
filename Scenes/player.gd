class_name Player extends CharacterBody2D

enum PlayerStates {IDLE,RUN,DASH,ATTACK}

static var player:Player

const SPEED:float = 140
const DASH_SPEED:float = 400

var is_flipped: bool = false
var dash_input: bool = false
var direction: Vector2 = Vector2.ZERO
var is_dashing: bool = false
var is_sword_exists: bool = false


var current_player_state:PlayerStates = PlayerStates.IDLE

@export var dash_timer: Timer
@export var dash_cooldown_timer: Timer
@export var sword_area_2d: Area2D
@export var dash_particles_2d: GPUParticles2D
@export var animated_sprite_2d: AnimatedSprite2D

@onready var sword_placeholder: Sprite2D = $SwordPlaceholder
@onready var sword_collider: CollisionPolygon2D = $SwordPlaceholder/SwordArea2D/SwordCollider

@onready var attack_timer: Timer = $AttackTimer

func _ready():
	player = self
	remove_child(sword_placeholder)
	

func _physics_process(delta):
	
	direction = Input.get_vector("move_left", "move_right","move_up","move_down")  
	dash_input = Input.is_action_pressed("dash")
	
	match current_player_state:
		PlayerStates.IDLE:
			
			velocity = velocity.move_toward(Vector2.ZERO, SPEED)
			
			if direction:
				check_flipping()
				if dash_input and dash_cooldown_timer.is_stopped():
					current_player_state = PlayerStates.DASH
				current_player_state = PlayerStates.RUN
		PlayerStates.RUN:
			
			check_flipping()
			velocity = direction * SPEED
			
			if direction:
				if dash_input and dash_cooldown_timer.is_stopped():
					current_player_state = PlayerStates.DASH
			else:
				current_player_state = PlayerStates.IDLE
		PlayerStates.DASH:
			
			if dash_timer.is_stopped():
				start_dash_timer()
			var dash_velocity:Vector2 = DASH_SPEED * direction
			velocity = velocity.move_toward(dash_velocity, SPEED)
			
			pass
		PlayerStates.ATTACK:
			
			pass
	
	
	if Input.is_action_just_pressed("attack"):
		if (!is_sword_exists):
			add_child(sword_placeholder)
			attack_timer.start()
	
	move_and_slide()


func start_dash_timer():
	print("dash timer started")
	dash_particles_2d.emitting = true
	
	dash_timer.start()


func _on_dash_timer_timeout() -> void:
	print("dash timer finished")
	dash_particles_2d.emitting = false
	
	dash_cooldown_timer.start()
	if direction:
		current_player_state = PlayerStates.RUN
		print("changed from dash")
	else:
		current_player_state = PlayerStates.IDLE
		print("changed from dash")
		


func check_flipping():
	#flip to left + flip to right respectively
	if direction.x < -0.6 and  !is_flipped:
		scale.x = -1
		dash_particles_2d.scale =  Vector2(-1, 1)
		print(dash_particles_2d.scale)
		is_flipped = true
		#animated_sprite_2d.flip_h = true
	elif direction.x > 0.6 and is_flipped:
		scale.x = -1
		print(dash_particles_2d.scale)
		dash_particles_2d.scale =  Vector2(-1, 1)
		is_flipped = false
		#animated_sprite_2d.flip_h = false 


func check_animations():
	if direction:
		animated_sprite_2d.play("run")
	else: 
		animated_sprite_2d.play("idle")


func _on_dash_cooldown_timer_timeout():
	pass # Replace with function body.



func _on_attack_timer_timeout() -> void:
	is_sword_exists = false
	remove_child(sword_placeholder)
	pass # Replace with function body.


