class_name CardUICanvas extends CanvasLayer


enum CardSelected {NONE = -1, CARD1 = 1, CARD2 = 2, CARD3 = 3 , CARD4 = 4}

signal card_swapped(element_type)

@export var animation_player: AnimationPlayer
@export var card_swap_cooldown_timer: Timer 
@export var texture_progress_bar1: TextureProgressBar 
@export var texture_progress_bar2: TextureProgressBar 
@export var texture_progress_bar3: TextureProgressBar 
@export var texture_progress_bar4: TextureProgressBar 



var current_card_selected = CardSelected.NONE
var card_entered:bool = false
var is_input_ignored:bool = false
var num_key_pressed:int = -1

static var card_ui_cancas:CardUICanvas

func _ready() -> void:
	card_ui_cancas = self
	texture_progress_bar1.max_value = card_swap_cooldown_timer.wait_time
	texture_progress_bar1.step = card_swap_cooldown_timer.wait_time/50
	texture_progress_bar2.max_value = card_swap_cooldown_timer.wait_time
	texture_progress_bar2.step = card_swap_cooldown_timer.wait_time/50
	texture_progress_bar3.max_value = card_swap_cooldown_timer.wait_time
	texture_progress_bar3.step = card_swap_cooldown_timer.wait_time/50
	texture_progress_bar4.max_value = card_swap_cooldown_timer.wait_time
	texture_progress_bar4.step = card_swap_cooldown_timer.wait_time/50

func _process(_delta: float) -> void:
	#return any number key pressed between 1-4 but not anything else
	if !is_input_ignored:	
		num_key_pressed = get_card_input()
	
	texture_progress_bar1.value = card_swap_cooldown_timer.time_left
	texture_progress_bar2.value = card_swap_cooldown_timer.time_left
	texture_progress_bar3.value = card_swap_cooldown_timer.time_left
	texture_progress_bar4.value = card_swap_cooldown_timer.time_left
	
	
	match current_card_selected:
		CardSelected.NONE:
			current_card_selected = num_key_pressed as Player.ElementTypes
			
		CardSelected.CARD1:
			
			if !card_entered: 
				card_swapped.emit(current_card_selected)
				animation_player.play("card_1_enter")
				card_swap_cooldown_timer.start()
				print("timer started")
				card_entered = true
			
			if !card_swap_cooldown_timer.is_stopped():
				is_input_ignored = true
			else:
				is_input_ignored = false
			
			
			if num_key_pressed != current_card_selected:
				if card_swap_cooldown_timer.is_stopped():
					animation_player.play("card_1_exit")
			
			
		CardSelected.CARD2:
			
			if !card_entered: 
				card_swapped.emit(current_card_selected)
				animation_player.play("card_2_enter")
				card_swap_cooldown_timer.start()
				is_input_ignored = true
				card_entered = true
			
			if !card_swap_cooldown_timer.is_stopped():
				is_input_ignored = true
			else:
				is_input_ignored = false
			
			if num_key_pressed != current_card_selected:
				if card_swap_cooldown_timer.is_stopped():
					animation_player.play("card_2_exit")
			
		CardSelected.CARD3:
			
			
			if !card_entered: 
				card_swapped.emit(current_card_selected)
				animation_player.play("card_3_enter")
				card_swap_cooldown_timer.start()
				is_input_ignored = true
				card_entered = true
			
			if !card_swap_cooldown_timer.is_stopped():
				is_input_ignored = true
			else:
				is_input_ignored = false
			
			if num_key_pressed != current_card_selected:
				if card_swap_cooldown_timer.is_stopped():
					animation_player.play("card_3_exit")
			
		CardSelected.CARD4:
			
			
			if !card_entered: 
				card_swapped.emit(current_card_selected)
				animation_player.play("card_4_enter")
				card_swap_cooldown_timer.start()
				is_input_ignored = true
				card_entered = true
			
			if !card_swap_cooldown_timer.is_stopped():
				is_input_ignored = true
			else:
				is_input_ignored = false
			
			if num_key_pressed != current_card_selected:
				if card_swap_cooldown_timer.is_stopped():
					animation_player.play("card_4_exit")
				
			
	
	pass

func get_card_input() -> int:
	var card_1:bool = Input.is_action_just_pressed("card_1")
	var card_2:bool = Input.is_action_just_pressed("card_2")
	var card_3:bool = Input.is_action_just_pressed("card_3")
	var card_4:bool = Input.is_action_just_pressed("card_4")
	
	if card_1:
		return 1
	if card_2:
		return 2
	if card_3:
		return 3
	if card_4:
		return 4
	return num_key_pressed


func check_for_any_card_input() -> bool:
	
	var card_1:bool = Input.is_action_just_pressed("card_1")
	var card_2:bool = Input.is_action_just_pressed("card_2")
	var card_3:bool = Input.is_action_just_pressed("card_3")
	var card_4:bool = Input.is_action_just_pressed("card_4")
	
	if card_1 or card_2 or card_3 or card_4:
		return true
	else:
		return false

func change_selected_card():
	current_card_selected = num_key_pressed as Player.ElementTypes
	card_entered = false


func _on_card_swap_cooldown_timer_timeout() -> void:
	is_input_ignored = false
	print("ended")
