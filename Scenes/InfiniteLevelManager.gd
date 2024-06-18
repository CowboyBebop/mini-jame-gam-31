extends Node2D

@export var level_trigger: InfiniteLevelTrigger

@export var spawnpoint1: Marker2D
@export var spawnpoint2: Marker2D
@export var spawnpoint3: Marker2D
@export var spawnpoint4: Marker2D

@onready var wave_cooldown_timer: Timer = $WaveCooldownTimer

const MAX_SPAWNPOINT_DEVIATION = 16*5

var num_of_enemies_to_spawn:int = 1
var all_spawnpoints:Array[Marker2D]
var num_of_enemies_alive: int = 0


func _ready():
	level_trigger.area_entered.connect(on_level_trigger_entered)
	all_spawnpoints = [spawnpoint1,spawnpoint2,spawnpoint3, spawnpoint4]


func spawn_enemies():
	# Hardcoded enemy scenes because I got only 4 enemies rn
	var ALL_ENEMY_RESOURCES = [load("uid://d1qsfyynlbqto"),load("uid://gym838j02ixp"), load("uid://c5rqgwjdj85e2"),load("uid://dmhqwg5u48ief")]

	for i in num_of_enemies_to_spawn:

		var new_enemy = ALL_ENEMY_RESOURCES[i % ALL_ENEMY_RESOURCES.size()].instantiate()
		var spawn_deviation =  Vector2(randf_range(-MAX_SPAWNPOINT_DEVIATION,MAX_SPAWNPOINT_DEVIATION),randf_range(-MAX_SPAWNPOINT_DEVIATION,MAX_SPAWNPOINT_DEVIATION))

		get_tree().get_root().add_child(new_enemy)

		new_enemy.global_position = all_spawnpoints[i % all_spawnpoints.size()].global_position + spawn_deviation
		new_enemy.enemy_died.connect(remove_enemy_from_level)
		new_enemy.trigger_enemy()

		num_of_enemies_alive +=1

		
	num_of_enemies_to_spawn += 1


func remove_enemy_from_level():
	num_of_enemies_alive -=1
	if num_of_enemies_alive == 0:
		wave_cooldown_timer.start()


func _on_wave_cooldown_timer_timeout():
	spawn_enemies()


func on_level_trigger_entered(_area):
	call_deferred("spawn_enemies")
