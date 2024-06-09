extends Area2D

@export var attack_element:Player.ElementTypes = Player.ElementTypes.FIRE

const BULLET_SPEED:int = 50
#const PROJECTILE_GRAVITY:float = 0.0005 #to simulate the flamethrower gravity
const RANGE:int = 500
const DAMAGE:int = 1

var direction
#var down_gravity_accel:Vector2 = Vector2.ZERO
var travelled_distance = 0

func _physics_process(delta):
	
	# I assume that the engine calculates rotation starting from the right direction
	# So we rate the (1,0) by current rotation and we get the direction Vector
	var direction = Vector2.RIGHT.rotated(rotation)
	#down_gravity_accel.y += PROJECTILE_GRAVITY
	#position += direction * BULLET_SPEED * delta + down_gravity_accel
	position += direction * BULLET_SPEED * delta 
	
	
	travelled_distance += BULLET_SPEED * delta
	if travelled_distance > RANGE:
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	queue_free()	
	
	if area is PlayerHurtBox:
		area.take_damage(DAMAGE,attack_element)

	
