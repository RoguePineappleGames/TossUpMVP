extends State

const ANGLE_DEGREE_INCREMENT: float = 3

@export var attack_state: State

@onready var transition_timer: Timer = $TransitionTimer

func on_enter() -> void:
	character.rotation_degrees = 0

func state_physics_process(_delta) -> void:
	character.rotation_degrees += ANGLE_DEGREE_INCREMENT
	if int(character.rotation_degrees) == 360:
		Transitioned.emit(self, attack_state)
