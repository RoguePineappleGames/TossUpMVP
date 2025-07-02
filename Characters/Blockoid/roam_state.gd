extends State

@export var attack_state: State

@onready var transition_timer: Timer = $TransitionTimer

var rng = RandomNumberGenerator.new()
var angle_degree_increment: float = 0.75

func on_enter() -> void:
	character.rotation_degrees = 0
	

func state_physics_process(_delta) -> void:
	character.rotation_degrees += angle_degree_increment
	if int(character.rotation_degrees) == 360:
		Transitioned.emit(self, attack_state)
