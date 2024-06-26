extends CharacterBody2D

enum EnemyStates {IDLE,TRIGGERED,ATTACK}

signal enemy_died

const MAX_HEALTH = 5

var health:int = 0
var current_enemy_state = EnemyStates.IDLE
var is_flipped: bool = false
var is_sword_exists: bool = false
var direction_to_player: Vector2 = Vector2.ZERO
var distance_to_player: float = 0

@export var SPEED = 50
@export var attack_distance: float
@export var margin_distance: float 
@export var attack_timer: Timer
@export var enemy_health_bar: ProgressBar

@export var level_trigger: LevelTrigger

@onready var attack_cooldown_timer: Timer = $AttackCooldownTimer
@onready var hurt_box: HurtBox = $HurtBox
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready():
	if level_trigger:
		level_trigger.add_enemy_to_level(self)
		level_trigger.area_entered.connect(_on_level_trigger_area_entered)

	hurt_box.damage_taken.connect(_on_damage_taken)
	health = MAX_HEALTH
	enemy_health_bar.max_value = MAX_HEALTH

func _physics_process(_delta: float) -> void:

	direction_to_player = global_position.direction_to(Player.player.global_position)
	distance_to_player = global_position.distance_to(Player.player.global_position)
	
	match current_enemy_state:
		EnemyStates.IDLE:
			animation_player.play("idle")
			velocity = velocity.move_toward(Vector2.ZERO, SPEED)
			pass
			
		EnemyStates.TRIGGERED:
			animation_player.play("walk")
			check_flipping()
			
			if distance_to_player >= margin_distance:
				velocity = direction_to_player * SPEED
			
			if distance_to_player <= attack_distance:
				check_flipping()
				current_enemy_state = EnemyStates.ATTACK
				
		EnemyStates.ATTACK:
			velocity = Vector2.ZERO
			#print("not is_sword_exists: ", not is_sword_exists,"attack_cooldown_timer.is_stopped(): ", attack_cooldown_timer.is_stopped() )
			
			if attack_cooldown_timer.is_stopped():
				animation_player.play("attack")
				
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

func on_attack_animation_end():
	attack_cooldown_timer.start()
	current_enemy_state = EnemyStates.TRIGGERED
	
	
