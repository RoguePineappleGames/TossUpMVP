extends State

@export var dash_state: State
@export var grab_state: State

var input_vector:= Vector2.ZERO
var speed: int = 300

func state_input(event: InputEvent) -> void:
	input_vector = Input.get_vector("Left", "Right", "Up", "Down")
	
	if event.is_action_pressed("Dash"):
		Transitioned.emit(self, dash_state)
	
	if event.is_action_pressed("Grab"):
		Transitioned.emit(self, grab_state)
	

func state_physics_process(_delta):
	character.velocity = input_vector * speed
	
	character.move_and_slide()
