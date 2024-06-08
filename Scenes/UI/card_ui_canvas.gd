class_name CardUICanvas extends CanvasLayer


enum CardSelected {NONE = -1, CARD1 = 1, CARD2 = 2, CARD3 = 3 , CARD4 = 4}

signal card_swapped(ElementType)

@export var animation_player: AnimationPlayer

var current_card_selected = CardSelected.NONE
var card_entered:bool = false
var num_key_pressed:int = -1

func _process(_delta: float) -> void:
	num_key_pressed = check_card_input()
	
	match current_card_selected:
		CardSelected.NONE:
			
			current_card_selected = num_key_pressed
			
		CardSelected.CARD1:
			
			if !card_entered: 
				card_swapped.emit(current_card_selected-1)
				animation_player.play("card_1_enter")
				card_entered = true
			
			
			if num_key_pressed != current_card_selected:
				animation_player.play("card_1_exit")
			
		CardSelected.CARD2:
			
			if !card_entered: 
				card_swapped.emit(current_card_selected-1)
				animation_player.play("card_2_enter")
				card_entered = true
			if num_key_pressed != current_card_selected:
				animation_player.play("card_2_exit")
			
		CardSelected.CARD3:
				
			
			if !card_entered: 
				card_swapped.emit(current_card_selected-1)
				animation_player.play("card_3_enter")
				card_entered = true
			
			if num_key_pressed != current_card_selected:
				animation_player.play("card_3_exit")
			
		CardSelected.CARD4:
				
			
			if !card_entered: 
				card_swapped.emit(current_card_selected-1)
				animation_player.play("card_4_enter")
				card_entered = true
			
			if num_key_pressed != current_card_selected:
				animation_player.play("card_4_exit")
				
			
	
	pass

func check_card_input() -> int:
	
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

func check_any_card_input() -> bool:
	
	var card_1:bool = Input.is_action_just_pressed("card_1")
	var card_2:bool = Input.is_action_just_pressed("card_2")
	var card_3:bool = Input.is_action_just_pressed("card_3")
	var card_4:bool = Input.is_action_just_pressed("card_4")
	
	if card_1 or card_2 or card_3 or card_4:
		return true
	else:
		return false
		
		
func change_selected_card():
	current_card_selected = num_key_pressed
	card_entered = false
	
