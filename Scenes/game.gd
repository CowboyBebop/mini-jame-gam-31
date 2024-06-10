extends Node2D

@onready var game_over_ui: MarginContainer = $UICanvas/Game_OverUI
@onready var game_restart_timer: Timer = $GameRestartTimer
@onready var game_animation_player: AnimationPlayer = $GameAnimationPlayer
@onready var audio_stream_player: AudioStreamPlayer2D = $Player/AudioStreamPlayer
@onready var card_audio_stream_player: AudioStreamPlayer2D = $Player/CardAudioStreamPlayer



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	CardUICanvas.card_ui_cancas.card_swapped.connect(_on_card_swapped)
	Player.player.player_died.connect(on_player_death)
	Player.player.player_dying.connect(on_player_dying)
	game_animation_player.play("second_song")
	#game_animation_player.play("first_song")

func on_player_dying():
	audio_stream_player.stop()

func on_player_death():
	audio_stream_player.stop()	
	game_over_ui.visible = true
	game_restart_timer.start()

func _on_game_restart_timer_timeout() -> void:
	get_tree().reload_current_scene()

func on_first_song_ended():
	game_animation_player.play("second_song")
	
func _on_card_swapped(_element_type):
	card_audio_stream_player.stream = preload("uid://bt21qejjypere")
	card_audio_stream_player.play()
	
