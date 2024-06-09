class_name PlayerHurtBox extends Area2D

signal damage_taken(damage:int, element_type:int)
signal slow_area_changed(changed_to:bool)

func take_damage(damage:int,element_type:int):
	damage_taken.emit(damage,element_type)

func slow_area_change(changed_to:bool):
	slow_area_changed.emit(changed_to)
