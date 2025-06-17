extends State

@export var idle_state: State
@onready var transition_timer: Timer = $TransitionTimer

func on_enter():
	character.is_thrown = true
	print("We are thrown")

func state_physics_process(delta) -> void:
	#print("peepee")
	if character.is_thrown == false:
		Transitioned.emit(self, idle_state)
		return
	
	var collision = character.move_and_collide(character.velocity * delta)
	if collision:
		print(collision.get_collider())
		var collision_normal = collision.get_normal()
		character.velocity = character.velocity.bounce(collision_normal) * 0.2
		if transition_timer.is_stopped():
			transition_timer.start()


func _on_transition_timer_timeout() -> void:
	character.is_thrown = false
	#Transitioned.emit(self, idle_state)
