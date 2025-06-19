extends State

const BULLETSCENE = preload("res://Other/bullet.tscn")

@export var idle_state: State

@onready var transition_timer: Timer = $TransitionTimer

var bullet_direction_array: Array = [Vector2(0, -1), Vector2(1, -1), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1), Vector2(-1, 1), Vector2(-1, 0), Vector2(-1, -1)]

func on_enter() -> void:
	shoot_bullets()
	transition_timer.start()
	
func shoot_bullets():
	for bullet_direction in bullet_direction_array:
		var bullet_instance = BULLETSCENE.instantiate()
		get_tree().root.add_child(bullet_instance)
		bullet_instance.spawn(character.global_position, bullet_direction)


func _on_transition_timer_timeout() -> void:
	Transitioned.emit(self, idle_state)
