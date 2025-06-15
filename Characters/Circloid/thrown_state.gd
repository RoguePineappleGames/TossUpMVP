extends State

@export var idle_state: State
@onready var transition_timer: Timer = $TransitionTimer

func on_enter():
	#character.move_and_slide()
	print("We are thrown")

func state_physics_process(delta) -> void:
	#print("peepee")
	var collision = character.move_and_collide(character.velocity * delta)
	if collision:
		#Add bounce
		var collision_normal = collision.get_normal()
		character.velocity = character.velocity.bounce(collision_normal)
		character.velocity *= 0.1
		character.is_thrown = false
		print("We collided somewhere")
		
	else:
		character.move_and_slide()
		###is on_floor_only is too slow here, so we check if the collision normal is facing vertically up
		#if collision_normal.y < -0.7:
			##print("We landed on the floor after being thrown")
			#character.is_thrown = false
			#character.velocity = Vector2.ZERO
	#print("We threw ", character.is_thrown)
	if not character.is_thrown:
		transition_timer.start()


func _on_transition_timer_timeout() -> void:
	Transitioned.emit(self, idle_state)
