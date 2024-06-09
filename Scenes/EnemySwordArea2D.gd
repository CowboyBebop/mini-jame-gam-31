extends Area2D

@export var damage:int = 2
@export var attack_element:Player.ElementTypes = Player.ElementTypes.NONE
@onready var sword_collider: CollisionPolygon2D = $SwordCollider

func _on_area_entered(area: Area2D) -> void:
	if area is PlayerHurtBox:
		sword_collider.set_deferred("disable", true)
		area.take_damage(damage,attack_element)
