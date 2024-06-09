class_name LevelTrigger extends Area2D


@onready var level_trigger_collider: CollisionShape2D = $LevelTriggerCollider

@export var gate_1: Node2D
@export var gate_2: Node2D

@export var gate_1_collider: CollisionShape2D
@export var gate_2_collider: CollisionShape2D

var level_enemies: Array[Node2D]

func add_enemy_to_level(enemy:Node2D):
	level_enemies.append(enemy)

func _ready() -> void:
	#level_started()


func _physics_process(delta: float) -> void:
	for i in level_enemies.size():
		if level_enemies[i] == null:
			level_enemies.remove_at(i)
			print("removed enemy")
			pass
	if level_enemies.size() == 0:
		#level_finished()
		pass

func _on_area_entered(area: Area2D) -> void:
	level_trigger_collider.disabled = true


func level_started():
	gate_1.visible = true
	gate_2.visible = true
	gate_1_collider.disabled = false
	gate_2_collider.disabled = false


func level_finished():
	gate_1.visible = false
	gate_2.visible = false
	gate_1_collider.disabled = true
	gate_2_collider.disabled = true
