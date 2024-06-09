extends Area2D

@export var damage:int = 1
@export var attack_element:Player.ElementTypes = Player.ElementTypes.NONE
@onready var sword_collider: CollisionPolygon2D = $SwordCollider

func _on_area_entered(area: Area2D) -> void:
	sword_collider.set_deferred("disabled",true)
	
	if area is PlayerHurtBox:
		area.take_damage(damage,attack_element)
