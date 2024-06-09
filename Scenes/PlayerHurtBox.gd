class_name PlayerHurtBox extends Area2D

signal damage_taken(damage:int, element_type:int)
signal slow_state_changed(speed:bool)

func take_damage(damage:int,element_type:int):
	damage_taken.emit(damage,element_type)

func change_slow_state(changed_to:bool):
	slow_state_changed.emit(changed_to)
