extends CharacterBody2D

enum PlayerStates {IDLE,RUN,DASH,ATTACK}

const SPEED:float = 140
const DASH_SPEED:float = 400

var is_flipped: bool = false
var dash_input: bool = false
var direction: Vector2 = Vector2.ZERO
var is_dashing: bool = false

var current_player_state:PlayerStates = PlayerStates.IDLE

@export var dash_timer: Timer
@export var dash_cooldown_timer: Timer
@export var animated_sprite_2d: AnimatedSprite2D

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
	
	move_and_slide()


func start_dash_timer():
	print("dash timer started")
	dash_timer.start()


func _on_dash_timer_timeout() -> void:
	print("dash timer finished")
	
	dash_cooldown_timer.start()
	if direction:
		current_player_state = PlayerStates.RUN
		print("changed from dash")
	else:
		current_player_state = PlayerStates.IDLE
		print("changed from dash")
		


func check_flipping():
	if direction.x < -0.6 and  !is_flipped:
		scale.x = -1
		is_flipped = true
		#animated_sprite_2d.flip_h = true
	elif direction.x > 0.6 and is_flipped:
		scale.x = -1
		is_flipped = false
		#animated_sprite_2d.flip_h = false 


func check_animations():
	if direction:
		animated_sprite_2d.play("run")
	else: 
		animated_sprite_2d.play("idle")


func _on_dash_cooldown_timer_timeout():
	pass # Replace with function body.
