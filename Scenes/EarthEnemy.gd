extends CharacterBody2D

enum EnemyStates {IDLE,TRIGGERED,ATTACK}

const SPEED = 50
const MAX_HEALTH = 5

var health:int = 0
var current_enemy_state = EnemyStates.IDLE
var is_flipped: bool = false
var is_sword_exists: bool = false
var direction_to_player: Vector2 = Vector2.ZERO
var distance_to_player: float = 0

@export var attack_distance:float
@export var attack_timer: Timer

@export var level_trigger: LevelTrigger

@onready var sword_placeholder: Sprite2D = $SwordPlaceholder
@onready var hurt_box: HurtBox = $HurtBox
@onready var enemy_health_bar: ProgressBar = $EnemyHealthBar


func _ready():
	level_trigger.add_enemy_to_level(self)
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
			
			if (!is_sword_exists):
				add_child(sword_placeholder)
				attack_timer.start()
				is_sword_exists = true
				
			
			
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
	#print("tuneiy")
	remove_child(sword_placeholder)
	is_sword_exists = false
	current_enemy_state = EnemyStates.TRIGGERED
	
	pass # Replace with function body


func _on_damage_taken(damage:int) -> void:
	health -= damage
	enemy_health_bar.value = health
	check_health()
	print("damage taken: ", health)
	
func check_health():
	if health <= 0:
		# do death anim here
		#animation_player.play("death")
		queue_free()
