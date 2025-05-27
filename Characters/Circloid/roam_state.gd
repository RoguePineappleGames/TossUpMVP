extends State

class_name PatrolState 

@export var idle_state: State

@onready var patrol_timer: Timer = $PatrolTimer


func on_enter():
	patrol_timer.start()

func _on_patrol_timer_timeout() -> void:
	Transitioned.emit(self, idle_state)
