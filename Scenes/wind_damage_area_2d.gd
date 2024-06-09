extends Area2D

@export var damage:int = 1
@export var attack_element:Player.ElementTypes = Player.ElementTypes.WIND

func _on_area_entered(area: Area2D) -> void:
	if area is PlayerHurtBox:
		area.take_damage(damage,attack_element)
