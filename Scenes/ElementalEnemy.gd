extends CharacterBody2D

enum EnemyStates {IDLE,TRIGGERED,ATTACK}

const SPEED = 100.0

var current_enemy_state = EnemyStates.IDLE
var is_flipped: bool = false
var direction_to_player: Vector2 = Vector2.ZERO

@export var level_trigger: Area2D
@onready var raycast_to_player_2d: RayCast2D = $RaycastToPlayer2D

func _ready():
	level_trigger.body_entered.connect(_on_level_trigger_area_entered)

func _physics_process(delta: float) -> void:

	direction_to_player = global_position.direction_to(Player.player.global_position)
	
	match current_enemy_state:
		EnemyStates.IDLE:
			pass
		EnemyStates.TRIGGERED:
			check_flipping()
			
			velocity = direction_to_player * SPEED
		EnemyStates.ATTACK:
			
			pass
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
