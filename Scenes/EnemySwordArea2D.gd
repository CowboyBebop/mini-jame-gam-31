extends Area2D

@export var damage:int = 2
@export var attack_element:Player.ElementTypes = Player.ElementTypes.NONE
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

func _on_area_entered(area: Area2D) -> void:
	if area is PlayerHurtBox:
		collision_shape_2d.set_deferred("disable", true)
		area.take_damage(damage,attack_element)
