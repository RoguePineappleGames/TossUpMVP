extends State

class_name IdleState

@export var roam_state: State
@export var stun_state: State

@onready var idle_timer: Timer = $IdleTimer

func on_enter():
	idle_timer.start()
	


func _on_idle_timer_timeout() -> void:
	Transitioned.emit(self, roam_state)
