extends Area2D

@export var damage:int = 1
@export var attack_element:Player.ElementTypes = Player.ElementTypes.NONE
@onready var sword_collider: CollisionPolygon2D = $SwordCollider

func _on_area_entered(area: Area2D) -> void:
	print("colliding")
	#sword_collider.disabled = true
	sword_collider.set_deferred("disabled",true)
	print("disabled collider", sword_collider.disabled)
	
	if area is PlayerHurtBox:
		area.take_damage(damage,attack_element)
