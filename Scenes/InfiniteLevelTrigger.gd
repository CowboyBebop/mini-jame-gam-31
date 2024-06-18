class_name InfiniteLevelTrigger extends Area2D


@onready var level_trigger_collider: CollisionShape2D = $LevelTriggerCollider

@export var gate_1: Node2D
@export var gate_1_collider: CollisionShape2D


func _physics_process(_delta: float) -> void:
	pass

func _on_area_entered(_area: Area2D) -> void:
	level_trigger_collider.set_deferred("disabled",true)
	gate_1_collider.set_deferred("disabled",false)
	gate_1.visible = true


func level_finished():
	gate_1.visible = false
	gate_1_collider.disabled = true
