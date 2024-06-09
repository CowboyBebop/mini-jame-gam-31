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
var margin_distance: float = 30
@export var attack_distance:float
@export var attack_timer: Timer
@export var enemy_health_bar: ProgressBar

@export var level_trigger: LevelTrigger

@onready var attack_cooldown_timer: Timer = $AttackCooldownTimer
@onready var sword_placeholder: Sprite2D = $SwordPlaceholder
@onready var hurt_box: HurtBox = $HurtBox
@onready var sword_collider: CollisionPolygon2D = $SwordPlaceholder/SwordArea2D/SwordCollider


func _ready():
	level_trigger.add_enemy_to_level(self)
	level_trigger.area_entered.connect(_on_level_trigger_area_entered)
	hurt_box.damage_taken.connect(_on_damage_taken)
	sword_placeholder.visible=false
	sword_collider.disabled=true
	
	#remove_child(sword_placeholder)
	
	health = MAX_HEALTH
	enemy_health_bar.max_value = MAX_HEALTH

func _physics_process(delta: float) -> void:

	direction_to_player = global_position.direction_to(Player.player.global_position)
	distance_to_player = global_position.distance_to(Player.player.global_position)
	
	match current_enemy_state:
		EnemyStates.IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, SPEED)
			pass
			
		EnemyStates.TRIGGERED:
			check_flipping()
			
			
			if distance_to_player >= margin_distance:
				velocity = direction_to_player * SPEED
			else:
				velocity = Vector2.ZERO
			
			if distance_to_player <= attack_distance:
				#print("player in distance",attack_cooldown_timer.is_stopped())
				#if attack_cooldown_timer.is_stopped():
				current_enemy_state = EnemyStates.ATTACK
				
		EnemyStates.ATTACK:
			velocity = Vector2.ZERO
			#print("not is_sword_exists: ", not is_sword_exists,"attack_cooldown_timer.is_stopped(): ", attack_cooldown_timer.is_stopped() )
			
			if not is_sword_exists and attack_cooldown_timer.is_stopped():
				sword_placeholder.visible = true
				sword_collider.disabled = false
				
				is_sword_exists = true
				attack_timer.start()
				
			if distance_to_player > attack_distance:
				current_enemy_state = EnemyStates.TRIGGERED
			
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
	attack_cooldown_timer.start()
	sword_placeholder.visible = false
	sword_collider.disabled = true
	is_sword_exists = false
	current_enemy_state = EnemyStates.TRIGGERED
	
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


