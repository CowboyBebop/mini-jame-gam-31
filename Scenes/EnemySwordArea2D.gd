extends Area2D

#var attack_element:Player.ElementTypes

func _on_sword_area_2d_area_entered(area: Area2D) -> void:
	#dsword_collider.set_deferred("disabled", true)
	#sword_collider.disabled = true	
	if area is PlayerHurtBox:
		area.take_damage(1)
