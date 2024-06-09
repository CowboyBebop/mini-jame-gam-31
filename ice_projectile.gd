extends Area2D

@export var attack_element:Player.ElementTypes = Player.ElementTypes.ICE

const BULLET_SPEED:int = 75
#const PROJECTILE_GRAVITY:float = 0.0005 #to simulate the flamethrower gravity
const RANGE:int = 800
const DAMAGE:int = 0

var direction
#var down_gravity_accel:Vector2 = Vector2.ZERO
var travelled_distance = 0

func _physics_process(delta):
	
	position += direction * BULLET_SPEED * delta 
	
	travelled_distance += BULLET_SPEED * delta
	
	
	if travelled_distance > RANGE:
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	
	print(get_parent())
	const PROJECTILE = preload("uid://cocbdi33rhrjs")
	var new_projectile = PROJECTILE.instantiate()
	
	get_parent().add_child(new_projectile)
	new_projectile.global_position = global_position
	queue_free()
	


