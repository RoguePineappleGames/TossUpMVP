extends Node

class_name CharacterStateMachine

@export var character: CharacterBody2D
@export var initial_state : State 
var states_array : Array[State]
var current_state : State

# Called when the node enters the scene tree for the first time.
func _ready():
	##connect character's transitioned signal to allow exceptional transitions
	character.ExceptionalTransition.connect(on_state_transition)
	
	## get children under CharacterStateMachine node
	for child in get_children():
		##checking if the child is a state
		if child is State:
			##add to our array
			states_array.append(child)
			##define the character they affect
			child.character = character
			##Connect transition function
			child.Transitioned.connect(on_state_transition)

			## DEBUGGING
			#print(child)
			## END DEBUGGING
			
		else:
			push_warning("Warning, child " + child.name + " is not a State ya kos omak")
	
	if initial_state:
		initial_state.on_enter()
		current_state = initial_state
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	##run state_process of current state
	current_state.state_physics_process(delta)
	
func can_move():
	return current_state.can_move

func _input(event: InputEvent):
	current_state.state_input(event)

func on_state_transition(calling_state : State, next_state : State):
	#if the state calling the function is not the current state, ignore
	if calling_state != current_state:
		print("Error: Next state - ", next_state, " - is not in the State Array")
		return
	if next_state not in states_array:
		print("Error: Next state - ", next_state, " - is not in the State Array")
		return
		
	#print("Transitioning from ", current_state, " to ", next_state)
	
	## Call on_exit function of current state
	current_state.on_exit()
	
	## Store current_state as previous state of the next_state
	next_state.previous_state = current_state
	
	# change current_state to next_state
	current_state = next_state
	## call the on_enter function of our new current_state
	current_state.on_enter()
