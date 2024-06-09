extends Node2D

@onready var game_over_ui: MarginContainer = $UICanvas/Game_OverUI
@onready var game_restart_timer: Timer = $GameRestartTimer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Player.player.player_died.connect(on_player_death)


func on_player_death():
	game_over_ui.visible = true
	game_restart_timer.start()


func _on_game_restart_timer_timeout() -> void:
	get_tree().reload_current_scene()
