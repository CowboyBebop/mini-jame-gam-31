extends CharacterBody2D

enum EnemyStates {IDLE,CHARGE,DASH}

signal enemy_died

const SPEED = 40
const DASH_SPEED = 500
const MAX_HEALTH:float = 4.0

var health:float = 0
var current_enemy_state = EnemyStates.IDLE
var is_flipped: bool = false
var is_on_cooldown: bool = false
var is_colliding_with_wall: bool = false
var direction_to_player: Vector2 = Vector2.ZERO
var distance_to_player: float = 0

#dash logic
var position_to_dash_to: Vector2 = Vector2.ZERO
var starting_dash_pos: Vector2 = Vector2.ZERO
var direction_to_dash: Vector2 = Vector2.ZERO

@export var attack_distance:float
@export var attack_timer: Timer
@export var enemy_health_bar: ProgressBar
@export var level_trigger: LevelTrigger


@onready var hurt_box: HurtBox = $HurtBox
@onready var projectile_marker_2d: Marker2D = $ProjectileMarker2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D


func _ready():
	if level_trigger:
		level_trigger.add_enemy_to_level(self)
		level_trigger.area_entered.connect(_on_level_trigger_area_entered)
	hurt_box.damage_taken.connect(_on_damage_taken)
	health = MAX_HEALTH
	enemy_health_bar.max_value = MAX_HEALTH
	enemy_health_bar.value = health

func _physics_process(_delta: float) -> void:

	direction_to_player = global_position.direction_to(Player.player.global_position)
	distance_to_player = global_position.distance_to(Player.player.global_position)
	
	match current_enemy_state:
		EnemyStates.IDLE:
			check_flipping()
			velocity = velocity.move_toward(Vector2.ZERO, SPEED)
			pass
			
		EnemyStates.CHARGE:
			check_flipping()
			animation_player.play("charge")
			
		EnemyStates.DASH:
			check_flipping()
			animation_player.play("dash")
			
			var distance_to_dash_target:float = (position_to_dash_to - global_position).length()
			
			if(distance_to_dash_target < 100):
				
				velocity = Vector2.ZERO
				global_position = global_position.move_toward(position_to_dash_to, distance_to_dash_target/8)
				#print("distance_to_dash_target: ", distance_to_dash_target)
				if(distance_to_dash_target < 5):
					velocity = Vector2.ZERO
					current_enemy_state = EnemyStates.CHARGE
			else:
				velocity = (position_to_dash_to - global_position).normalized() * DASH_SPEED
				print("velocity: ", velocity.length())
				#if velocity.length() < 1:
					#velocity = Vector2.ZERO
					#current_enemy_state = EnemyStates.CHARGE
	
	
	move_and_slide()

func _on_level_trigger_area_entered(_body:Node2D):
	current_enemy_state = EnemyStates.CHARGE

func trigger_enemy():
	current_enemy_state = EnemyStates.CHARGE

func check_flipping():
	if direction_to_player.x < -0.6 and  !is_flipped:
		scale.x = -1
		is_flipped = true
		#animated_sprite_2d.flip_h = true
	elif direction_to_player.x > 0.6 and is_flipped:
		scale.x = -1
		is_flipped = false
		#animated_sprite_2d.flip_h = false 


func _on_attack_timer_timeout() -> void:
	is_on_cooldown = false


func _on_damage_taken(damage:int) -> void:
	audio_stream_player_2d.stream = preload("uid://bfrqratkie3ns")
	audio_stream_player_2d.play()
	health -= damage
	enemy_health_bar.value = health
	check_health()
	
func check_health():
	if health <= 0:
		#animation_player.play("death")
		if level_trigger:
			level_trigger.remove_enemy_from_level(self)
		enemy_died.emit()
		queue_free()
	
	
func dash_start():
	starting_dash_pos = global_position
	direction_to_dash = starting_dash_pos.direction_to(Player.player.global_position)
	position_to_dash_to = Player.player.global_position + direction_to_dash * (100) # a slight offset beyond player pos
	current_enemy_state = EnemyStates.DASH





func _on_collider_area_2d_body_entered(body: Node2D) -> void:
	velocity = Vector2.ZERO
	current_enemy_state = EnemyStates.CHARGE
	#is_colliding_with_wall = true


func _on_collider_area_2d_body_exited(body: Node2D) -> void:
	is_colliding_with_wall = false
