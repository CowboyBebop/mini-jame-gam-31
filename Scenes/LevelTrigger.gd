class_name LevelTrigger extends Area2D


@onready var level_trigger_collider: CollisionShape2D = $LevelTriggerCollider

@export var gate_1: Node2D
@export var gate_2: Node2D

@export var gate_1_collider: CollisionShape2D
@export var gate_2_collider: CollisionShape2D

var level_enemies: Array[Node2D]

var has_started_level:bool = false

func _ready() -> void:
	pass

func add_enemy_to_level(enemy:Node2D):
	level_enemies.append(enemy)

func remove_enemy_from_level(enemy:Node2D):
	level_enemies.erase(enemy)	

func _physics_process(delta: float) -> void:
	#print(level_enemies.size(),level_enemies[0],level_enemies[1])
	
	#print(level_enemies.size())
	if has_started_level and level_enemies.size() == 0:
		level_finished()
		pass

func _on_area_entered(area: Area2D) -> void:
	level_trigger_collider.set_deferred("disabled",true)
	#level_trigger_collider.disabled = true
	level_started()


func level_started():
	has_started_level = true
	gate_1.visible = true
	gate_2.visible = true
	gate_1_collider.set_deferred("disabled",false)
	gate_2_collider.set_deferred("disabled",false)
	print("colliders disableds",gate_2_collider.disabled)


func level_finished():
	print("colliders asd",gate_2_collider.disabled)
	Player.player.add_health(1)
	
	gate_1.visible = false
	gate_2.visible = false
	gate_1_collider.disabled = true
	gate_2_collider.disabled = true
