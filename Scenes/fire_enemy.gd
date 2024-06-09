extends CharacterBody2D

enum EnemyStates {IDLE,TRIGGERED,ATTACK}

const SPEED = 50
const MAX_HEALTH = 5

var health:int = 0
var current_enemy_state = EnemyStates.IDLE
var is_flipped: bool = false
var is_sword_exists: bool = false
var is_on_cooldown: bool = false
var direction_to_player: Vector2 = Vector2.ZERO
var distance_to_player: float = 0

@export var attack_distance:float
@export var attack_timer: Timer

@export var level_trigger: Area2D

@onready var sword_placeholder: Sprite2D = $SwordPlaceholder
@onready var hurt_box: HurtBox = $HurtBox
@onready var enemy_health_bar: ProgressBar = $EnemyHealthBar
@onready var projectile_marker_2d: Marker2D = $ProjectileMarker2D


func _ready():
	level_trigger.area_entered.connect(_on_level_trigger_area_entered)
	hurt_box.damage_taken.connect(_on_damage_taken)
	remove_child(sword_placeholder)
	health = MAX_HEALTH
	enemy_health_bar.max_value = MAX_HEALTH
	enemy_health_bar.value = health

func _physics_process(delta: float) -> void:

	direction_to_player = global_position.direction_to(Player.player.global_position)
	distance_to_player = global_position.distance_to(Player.player.global_position)
	
	match current_enemy_state:
		EnemyStates.IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, SPEED)
			pass
			
		EnemyStates.TRIGGERED:
			check_flipping()
			
			velocity = direction_to_player * SPEED
			if distance_to_player < attack_distance:
				current_enemy_state = EnemyStates.ATTACK
				
		EnemyStates.ATTACK:
			velocity = Vector2.ZERO
			
			if not is_on_cooldown:
				shoot_projectile()
				attack_timer.start()
				is_on_cooldown = true
	
	#print(distance_to_player, attack_distance, distance_to_player < attack_distance)
	
	move_and_slide()

func _on_level_trigger_area_entered(body:Node2D):
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


func _on_attack_timer_timeout() -> void:
	is_on_cooldown = false


func shoot_projectile():
	pass
	#const PROJECTILE = preload("uid://cmrc5hawu0s3l")
	#var new_projectile = PROJECTILE.instantiate()
	#new_projectile.global_position = projectile_marker_2d.global_position
	#new_projectile.rotation = rotation
	#add_child(new_projectile)
			

func _on_damage_taken(damage:int) -> void:
	health -= damage
	enemy_health_bar.value = health
	print("damage taken: ", health)
