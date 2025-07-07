extends State

class_name ThrownState

@export var idle_state: State

@onready var transition_timer: Timer = $TransitionTimer
@onready var enemy_detector: Area2D = $"../../EnemyDetector"

func on_enter():
	character.is_thrown = true
	enemy_detector.monitoring = true

func state_physics_process(delta) -> void:
	if character.is_thrown == false:
		Transitioned.emit(self, idle_state)
		return
	
	var collision = character.move_and_collide(character.velocity * delta)
	if collision:
		var collision_normal = collision.get_normal()
		character.velocity = character.velocity.bounce(collision_normal) * 0.2
		if transition_timer.is_stopped():
			transition_timer.start()

func _on_enemy_detector_body_entered(body: Node2D) -> void:
	##couldn't fix this in any other way
	##Check if we collided with ourselves and exit the function if so
	if body == character:
		return
	var my_type = character.shape_type
	var other_type = body.shape_type
	
	if ShapeLogic.does_shape_beat_shape(my_type, other_type):
		body.die(character.HIGH_SCORE)
	elif my_type == other_type:
		body.die(character.LOW_SCORE)
		character.die(character.LOW_SCORE)
	
func _on_transition_timer_timeout() -> void:
	character.is_thrown = false
	enemy_detector.monitoring = false
