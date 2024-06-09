extends Area2D

@onready var slow_area_timer: Timer = $SlowAreaTimer

func _ready() -> void:
	slow_area_timer.start()

func _on_area_entered(area: Area2D) -> void:
	if area is PlayerHurtBox:
		area.change_slow_state(true)

func _on_area_exited(area: Area2D) -> void:
	if area is PlayerHurtBox:
		area.change_slow_state(false)


func _on_slow_area_timer_timeout() -> void:
	queue_free()
