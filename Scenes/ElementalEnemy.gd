extends CharacterBody2D

enum EnemyStates {IDLE,TRIGGERED,ATTACK}

const SPEED = 100.0

var current_enemy_state = EnemyStates.IDLE
var is_flipped: bool = false
var is_sword_exists: bool = false
var direction_to_player: Vector2 = Vector2.ZERO
var distance_to_player: float = 0

@export var attack_distance:float
@export var level_trigger: Area2D

@onready var raycast_to_player_2d: RayCast2D = $RaycastToPlayer2D
@onready var attack_timer: Timer = $AttackTimer
@onready var sword_placeholder: Sprite2D = $SwordPlaceholder

func _ready():
	level_trigger.body_entered.connect(_on_level_trigger_area_entered)
	remove_child(sword_placeholder)

func _physics_process(delta: float) -> void:

	direction_to_player = global_position.direction_to(Player.player.global_position)
	distance_to_player = global_position.distance_to(Player.player.global_position)
	
	match current_enemy_state:
		EnemyStates.IDLE:
			pass
			
		EnemyStates.TRIGGERED:
			check_flipping()
			
			velocity = direction_to_player * SPEED
			
			if distance_to_player < attack_distance:
				current_enemy_state = EnemyStates.ATTACK
				
		EnemyStates.ATTACK:
			if (!is_sword_exists):
				add_child(sword_placeholder)
				attack_timer.start()
			
			
	move_and_slide()

func _on_level_trigger_area_entered(body:):
	current_enemy_state = EnemyStates.TRIGGERED

func check_flipping():
	print(direction_to_player)
	if direction_to_player.x < -0.6 and  !is_flipped:
		scale.x = -1
		is_flipped = true
		#animated_sprite_2d.flip_h = true
	elif direction_to_player.x > 0.6 and is_flipped:
		scale.x = -1
		is_flipped = false
		#animated_sprite_2d.flip_h = false 


func _on_attack_timer_timeout() -> void:
	is_sword_exists = false
	remove_child(sword_placeholder)
	pass # Replace with function body
