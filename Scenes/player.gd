class_name Player extends CharacterBody2D

signal player_died
signal player_dying

enum PlayerStates {IDLE,RUN,DASH,ATTACK,DYING,DEAD}
enum ElementTypes {NONE,ICE,FIRE,EARTH,WIND}

static var player:Player

const SLOW_SPEED:float = 25
const NORMAL_SPEED:float = 140
const DASH_SPEED:float = 400
const MAX_HEALTH:float = 3

var damage:int = 1
var current_speed :float = 140
var health:float = 3
var is_flipped: bool = false
var dash_input: bool = false
var direction: Vector2 = Vector2.ZERO
var is_dashing: bool = false
var is_sword_exists: bool = false
var is_inside_slow_area = false
var last_direction: Vector2 = Vector2.ZERO

var current_player_state:PlayerStates = PlayerStates.IDLE
var current_element_resistance:ElementTypes = ElementTypes.NONE

var player_particle_process_material: ParticleProcessMaterial

@export var dash_timer: Timer
@export var dash_cooldown_timer: Timer
@export var sword_area_2d: Area2D
@export var dash_particles_right: GPUParticles2D
@export var dash_particles_left: GPUParticles2D
@export var animation_player: AnimationPlayer
@export var player_hurt_box: PlayerHurtBox
@export var is_ignoring_input:bool = false

@export var ui_canvas_script: CardUICanvas
@export var health_bar: ProgressBar 
@export var player_shader: ShaderMaterial

@onready var hurt_box_collider_2d: CollisionShape2D = $PlayerHurtBox/HurtBoxCollider2D
@onready var immunity_particles: GPUParticles2D = $ImmunityParticles
@onready var sword_collider: CollisionPolygon2D = $SwordArea2D/SwordCollider
@onready var player_sprite: Sprite2D = $PlayerSprite
@onready var attack_timer: Timer = $AttackTimer
@onready var dash_invincibility_timer: Timer = $DashInvincibilityTimer

@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreams/AudioStreamPlayer2D
@onready var audio_stream_hurt_player: AudioStreamPlayer2D = $AudioStreams/AudioStreamHurtPlayer
@onready var audio_stream_dash: AudioStreamPlayer2D = $AudioStreams/AudioStreamDash
@onready var audio_stream_attack: AudioStreamPlayer2D = $AudioStreams/AudioStreamAttack


func _ready():
	player = self
	
	player_shader = player_sprite.material
	player_particle_process_material = immunity_particles.process_material as ParticleProcessMaterial
	
	ui_canvas_script.card_swapped.connect(_on_ui_card_swapped)
	player_hurt_box.damage_taken.connect(on_player_damage_taken)
	player_hurt_box.slow_area_changed.connect(_on_player_slow_area_changed)
	
	health = MAX_HEALTH
	health_bar.value = MAX_HEALTH

func _physics_process(_delta):
	calculate_slow_effect()
	
	if !is_ignoring_input:
		direction = Input.get_vector("move_left", "move_right","move_up","move_down")
		last_direction = direction
	else:
		direction = Vector2.ZERO
		
	dash_input = Input.is_action_pressed("dash")

	match current_player_state:
		PlayerStates.IDLE:
			animation_player.play("idle")
			
			velocity = velocity.move_toward(Vector2.ZERO, current_speed)
			if Input.is_action_just_pressed("attack"):
				current_player_state = PlayerStates.ATTACK
				
			if direction:
				check_flipping()
				if dash_input and dash_cooldown_timer.is_stopped():
					current_player_state = PlayerStates.DASH
				current_player_state = PlayerStates.RUN
				
				move_and_slide()
		PlayerStates.RUN:
			check_flipping()
			animation_player.play("run")
			
			if Input.is_action_just_pressed("attack"):
				is_ignoring_input = true;
				velocity = Vector2.ZERO
				current_player_state = PlayerStates.ATTACK
			else:
					velocity = direction * current_speed
			
			if direction:
				if dash_input and dash_cooldown_timer.is_stopped():
					current_player_state = PlayerStates.DASH
			else:
				current_player_state = PlayerStates.IDLE
				
			move_and_slide()
		PlayerStates.DASH:
			
			if dash_timer.is_stopped():
				audio_stream_dash.stream = preload("uid://c11u33l7v7wmk")
				audio_stream_dash.play()
				toggle_dash_particles(true)
				dash_timer.start()
				is_ignoring_input = true;
				if dash_invincibility_timer.is_stopped():
					dash_invincibility_timer.start()
					hurt_box_collider_2d.disabled = true
				
			var dash_velocity:Vector2 = DASH_SPEED * last_direction
			print(DASH_SPEED," ",last_direction, " ", dash_velocity)
			velocity = velocity.move_toward(dash_velocity, current_speed)
			
			move_and_slide()
			
		PlayerStates.ATTACK:
			velocity = last_direction * 15
			animation_player.play("attack")
			check_flipping()
			
			print("direction: ", direction, direction == Vector2(0,0), 
			" ignoring input? ", is_ignoring_input,
			" velocity ", velocity)
			
			if direction:
				if dash_input and dash_cooldown_timer.is_stopped():
					print("passed")
					current_player_state = PlayerStates.DASH
				else:
					current_player_state = PlayerStates.RUN
				
			move_and_slide()
			
		PlayerStates.DYING:
			velocity = Vector2.ZERO
			player_dying.emit()
			animation_player.play("death")
			current_player_state = PlayerStates.DEAD
			
		PlayerStates.DEAD:
			pass
	


func _on_dash_timer_timeout() -> void:
	print("dash timer finished")
	toggle_dash_particles(false)
	is_ignoring_input = false;
	
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
		elif direction.y > 0.6 or direction.y < -0.6:
			if is_flipped:
				dash_particles_left.emitting = true
			else:
				dash_particles_right.emitting = true
				

func check_flipping():
	#flip to left + flip to right respectively
	if direction.x < -0.6 and  !is_flipped:
		scale.x = -1
		is_flipped = true
	elif direction.x > 0.6 and is_flipped:
		scale.x = -1
		is_flipped = false

func _on_attack_timer_timeout() -> void:
	is_sword_exists = false
	sword_collider.disabled = false
	pass # Replace with function body.


func _on_sword_area_2d_area_entered(area: Area2D) -> void:
	print("colliding", sword_collider, sword_collider.disabled)
	sword_collider.set_deferred("disabled", true)
	
	#word_collider.disabled = true
	if area is HurtBox:
		area.take_damage(damage)
	
func _on_attack_animation_end():
	current_player_state = PlayerStates.IDLE
	
func on_player_damage_taken(damage_taken: int, element:ElementTypes):
	print("player damaged")
	if not current_element_resistance == element:
		health -=damage_taken
		health_bar.value = health
		audio_stream_hurt_player.stream = preload("uid://df3123yfie12i") #player hurt sfx
		audio_stream_hurt_player.play()
		check_health()
	else:
		print("damage negated") #add some effect or something to show that damage is negated


func _on_ui_card_swapped(element_type_int:int):
	current_element_resistance = element_type_int as ElementTypes
	
	match element_type_int:
		1:
			player_shader.set_shader_parameter("outline_color",Color.AQUA)
			#(player_sprite.material as ParticleProcessMaterial).color = Color.AQUA
			player_particle_process_material.color = Color.AQUA
		2:
			player_shader.set_shader_parameter("outline_color",Color.ORANGE_RED)
			player_particle_process_material.color = Color.ORANGE_RED
		3:
			player_shader.set_shader_parameter("outline_color",Color.DARK_ORANGE)
			player_particle_process_material.color = Color.DARK_ORANGE
		4:
			player_shader.set_shader_parameter("outline_color",Color.GREEN_YELLOW)
			player_particle_process_material.color = Color.GREEN_YELLOW

func _on_player_slow_area_changed(changed_to:bool):
	is_inside_slow_area = changed_to


func calculate_slow_effect():
	if is_inside_slow_area and current_element_resistance != ElementTypes.ICE:
		current_speed = SLOW_SPEED
	else:
		current_speed = NORMAL_SPEED

func add_health(heal:int):
	health += heal
	health_bar.value = health

func check_health():
	if health <= 0 and not current_player_state == PlayerStates.DYING and not current_player_state == PlayerStates.DEAD:
		current_player_state = PlayerStates.DYING
		print("died")

func played_death_anim_finished():
	player_died.emit()

func play_attack_sound():
	
	var rand:int = randi_range(1,4)
	match rand:
		1:
			audio_stream_attack.stream = preload("uid://cn1mgyf5nwpyf")
			audio_stream_attack.play()
		2:
			audio_stream_attack.stream = preload("uid://dvhoh1i5ucbvu")
			audio_stream_attack.play()
		3:
			audio_stream_attack.stream = preload("uid://da5d20i23qqha")
			audio_stream_attack.play()
		4:
			audio_stream_attack.stream = preload("uid://ycuirx0btw6r")
			audio_stream_attack.play()

func _on_dash_invincibility_timer_timeout() -> void:
	hurt_box_collider_2d.disabled = false
