extends CharacterBody2D

enum EnemyStates {IDLE,TRIGGERED,ATTACK}

signal enemy_died


const SPEED = 40
const MAX_HEALTH:float = 4.0

var health:float = 0
var current_enemy_state = EnemyStates.IDLE
var is_flipped: bool = false
var direction_to_player: Vector2 = Vector2.ZERO
var distance_to_player: float = 0

@export var attack_distance:float
@export var attack_timer: Timer
@export var level_trigger: LevelTrigger
@export var enemy_health_bar: ProgressBar


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
			animation_player.play("idle")
			check_flipping()
			velocity = velocity.move_toward(Vector2.ZERO, SPEED)
			pass
			
		EnemyStates.TRIGGERED:
			animation_player.play("walk")
			
			check_flipping()
			
			velocity = direction_to_player * SPEED
			if distance_to_player <= attack_distance:
				current_enemy_state = EnemyStates.ATTACK
				
		EnemyStates.ATTACK:
			check_flipping()
			velocity = Vector2.ZERO
			
			if  attack_timer.is_stopped():
				animation_player.play("attack")
				
			if distance_to_player > attack_distance:
				current_enemy_state = EnemyStates.TRIGGERED
			
	
	#print(distance_to_player, attack_distance, distance_to_player < attack_distance)
	
	move_and_slide()

func _on_level_trigger_area_entered(_body:Node2D):
	current_enemy_state = EnemyStates.TRIGGERED


func trigger_enemy():
	current_enemy_state = EnemyStates.TRIGGERED


func check_flipping():
	if direction_to_player.x < -0.6 and  !is_flipped:
		scale.x = -1
		is_flipped = true
		#animated_sprite_2d.flip_h = true
	elif direction_to_player.x > 0.6 and is_flipped:
		scale.x = -1
		is_flipped = false
		#animated_sprite_2d.flip_h = false 

func shoot_projectile():
	const PROJECTILE = preload("uid://buujabbngech0")
	var new_projectile = PROJECTILE.instantiate()
	new_projectile.global_position = projectile_marker_2d.global_position
	new_projectile.direction = projectile_marker_2d.global_position.direction_to(Player.player.global_position)
	get_parent().add_child(new_projectile)

func _on_damage_taken(damage:int) -> void:
	audio_stream_player_2d.stream = preload("uid://bfrqratkie3ns")
	audio_stream_player_2d.play()
	health -= damage
	enemy_health_bar.value = health
	check_health()
	print("damage taken: ", health)
	
func check_health():
	if health <= 0:
		# do death anim here
		#animation_player.play("death")
		if level_trigger:
			level_trigger.remove_enemy_from_level(self)
		enemy_died.emit()
		queue_free()

func on_shoot_animation_frame():
	shoot_projectile()
	attack_timer.start()
	
