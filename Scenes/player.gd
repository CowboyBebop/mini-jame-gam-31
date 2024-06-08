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
@export var dash_particles_right: GPUParticles2D
@export var dash_particles_left: GPUParticles2D
@export var animation_player: AnimationPlayer

@onready var sword_placeholder: Sprite2D = $SwordPlaceholder
@onready var sword_collider: CollisionPolygon2D = $SwordPlaceholder/SwordArea2D/SwordCollider
@onready var player_sprite: Sprite2D = $PlayerSprite

@onready var attack_timer: Timer = $AttackTimer

func _ready():
	player = self
	#remove_child(sword_placeholder)
	

func _physics_process(delta):
	
	direction = Input.get_vector("move_left", "move_right","move_up","move_down")  
	dash_input = Input.is_action_pressed("dash")
	
	match current_player_state:
		PlayerStates.IDLE:
			animation_player.play("idle")
			
			velocity = velocity.move_toward(Vector2.ZERO, SPEED)
			if Input.is_action_just_pressed("attack"):
				current_player_state = PlayerStates.ATTACK
				
				
			if direction:
				check_flipping()
				if dash_input and dash_cooldown_timer.is_stopped():
					current_player_state = PlayerStates.DASH
				current_player_state = PlayerStates.RUN
				
		PlayerStates.RUN:
			check_flipping()
			if Input.is_action_just_pressed("attack"):
				current_player_state = PlayerStates.ATTACK
			velocity = direction * SPEED
			animation_player.play("run")
			
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
			
			
		PlayerStates.ATTACK:
			animation_player.play("attack")
				
			
	
	
			#add_child(sword_placeholder)
			#attack_timer.start()
			#is_sword_exists = true
	
	move_and_slide()


func start_dash_timer():
	print("dash timer started")
	toggle_dash_particles(true)
	
	dash_timer.start()


func _on_dash_timer_timeout() -> void:
	print("dash timer finished")
	toggle_dash_particles(false)
	
	dash_cooldown_timer.start()
	if direction:
		current_player_state = PlayerStates.RUN
	else:
		current_player_state = PlayerStates.IDLE
		


func toggle_dash_particles(switch_to:bool):
	if switch_to == false:
		dash_particles_left.emitting = false
		dash_particles_right.emitting = false
	else:
		if direction.x < -0.6:
			dash_particles_left.emitting = true
		elif direction.x > 0.6:
			dash_particles_right.emitting = true

func check_flipping():
	#flip to left + flip to right respectively
	if direction.x < -0.6 and  !is_flipped:
		scale.x = -1
		is_flipped = true
	elif direction.x > 0.6 and is_flipped:
		scale.x = -1
		is_flipped = false

func _on_dash_cooldown_timer_timeout():
	pass # Replace with function body.

func _on_attack_timer_timeout() -> void:
	is_sword_exists = false
	remove_child(sword_placeholder)
	sword_collider.disabled = false
	pass # Replace with function body.



func _on_sword_area_2d_area_entered(area: Area2D) -> void:
	sword_collider.disabled = true
	if area is HurtBox:
		area.take_damage(1)
	
func _on_attack_animation_end():
	current_player_state = PlayerStates.IDLE
