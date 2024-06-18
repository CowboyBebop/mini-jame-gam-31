extends Node2D

@export var level_trigger: InfiniteLevelTrigger

@export var spawnpoint1: Marker2D
@export var spawnpoint2: Marker2D
@export var spawnpoint3: Marker2D
@export var spawnpoint4: Marker2D

@onready var wave_cooldown_timer: Timer = $WaveCooldownTimer

const spawnpoint_radius = 3

var num_of_enemies_to_spawn:int = 6
var all_spawnpoints:Array[Marker2D]
var num_of_enemies_alive: int = 0
var max_spawn_deviation:float = 2.5
# 1. player enters the area and event is sent here
# 2. wave started
# 3. enemies are spawned (wave is just enemy count +1)
# 4. if all enemies are dead wave is over, start a timer
# 5. on timer end, start another wave
# 6. repeat?


func _ready():
	level_trigger.area_entered.connect(on_level_trigger_entered)
	all_spawnpoints = [spawnpoint1,spawnpoint2,spawnpoint3, spawnpoint4]


func spawn_enemies():
	# Hardcoded enemy scenes because I got only 4 enemies rn
	const ALL_ENEMY_RESOURCES = [preload("uid://d1qsfyynlbqto"),preload("uid://gym838j02ixp"), preload("uid://c5rqgwjdj85e2"),preload("uid://dmhqwg5u48ief")]

	for i in num_of_enemies_to_spawn:
		print(num_of_enemies_to_spawn, "i: ", i )

		var new_enemy = ALL_ENEMY_RESOURCES[i % ALL_ENEMY_RESOURCES.size()].instantiate()
		new_enemy.global_position = all_spawnpoints[i % all_spawnpoints.size()].global_position + Vector2(randf_range(0,max_spawn_deviation),randf_range(0,max_spawn_deviation))
		num_of_enemies_alive +=1
		get_parent().add_child(new_enemy)

		new_enemy.enemy_died.connect(remove_enemy_from_level)
		new_enemy.trigger_enemy()
		
	num_of_enemies_to_spawn += 1


func remove_enemy_from_level():
	num_of_enemies_alive -=1
	if num_of_enemies_alive == 0:
		wave_cooldown_timer.start()


func _on_wave_cooldown_timer_timeout():
	spawn_enemies()


func on_level_trigger_entered(_area):
	spawn_enemies()
