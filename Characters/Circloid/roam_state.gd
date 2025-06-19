extends State

#class_name RoamState
const ROAMTIMERMIN: int = 5
const ROAMTIMERMAX: int = 10

@export var attack_state: State
@onready var roam_timer: Timer = $RoamTimer
@onready var direction_swap_timer: Timer = $DirectionSwapTimer

var direction_vector:= Vector2.ZERO
var roaming_speed: int = 100
var rng = RandomNumberGenerator.new()

func on_enter():
	randomize_direction_and_speed()
	direction_swap_timer.start()
	roam_timer.wait_time = rng.randi_range(5, 10)
	roam_timer.start()

func state_physics_process(_delta):
	character.velocity = direction_vector * roaming_speed
	character.move_and_slide()

func randomize_direction_and_speed() -> void: 
	direction_vector.x = rng.randf_range(-1, 1)
	direction_vector.y = rng.randf_range(-1, 1)
	roaming_speed = rng.randi_range(130, 150)

func _on_direction_swap_timer_timeout() -> void:
	randomize_direction_and_speed()

func _on_patrol_timer_timeout() -> void:
	Transitioned.emit(self, attack_state)

func on_exit():
	direction_swap_timer.stop()


func _on_wall_collision_detector_body_entered(_body: Node2D) -> void:
	#randomize_direction_and_speed()
	direction_vector *= -1
	direction_swap_timer.start()
