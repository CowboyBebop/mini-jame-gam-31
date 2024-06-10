extends Area2D

@export var damage:int = 2
@export var attack_element:Player.ElementTypes = Player.ElementTypes.NONE
@onready var collision_polygon_2d: CollisionPolygon2D = $CollisionPolygon2D

func _on_area_entered(area: Area2D) -> void:
	if area is PlayerHurtBox:
		collision_polygon_2d.set_deferred("disable", true)
		area.take_damage(damage,attack_element)
