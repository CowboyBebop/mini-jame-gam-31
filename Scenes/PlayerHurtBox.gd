class_name PlayerHurtBox extends Area2D

signal damage_taken(damage:int, element_type:int)

func take_damage(damage:int,element_type:int):
	damage_taken.emit(damage,element_type)
