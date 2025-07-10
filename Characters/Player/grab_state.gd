extends State

@export var move_state: State
@export var throw_state: State

@onready var enemy_detector: Area2D = $"../../EnemyDetector"
@onready var trajectory_line: Line2D = $TrajectoryLine

var input_vector:= Vector2.ZERO
var speed: int = 300
var start_drawing_line: bool = false

func on_enter() -> void:
	start_drawing_line = false
	
	var colliding_enemies = enemy_detector.get_overlapping_bodies()
	if colliding_enemies:
		for enemy in colliding_enemies:
			if enemy.is_stunned:
				enemy.grab()
				grab_enemy(enemy)
				return
	Transitioned.emit(self, move_state)

func grab_enemy(enemy: Enemy) -> void:
	character.grabbed_enemy = enemy
	enemy.reparent(character)
	var tween = create_tween()
	tween.tween_property(enemy, "position",  Vector2.ZERO, 0.4).set_trans(Tween.TRANS_EXPO)
	await tween.finished
	start_drawing_line = true


func set_trajectory_line() -> void:
	var mouse_position = character.get_global_mouse_position()
	trajectory_line.set_point_position(0, character.global_position)
	trajectory_line.set_point_position(1, mouse_position)

func disable_trajectory_line() -> void:
	trajectory_line.set_point_position(0, Vector2.ZERO)
	trajectory_line.set_point_position(1, Vector2.ZERO)
	
	
func state_input(event: InputEvent) -> void:
	input_vector = Input.get_vector("Left", "Right", "Up", "Down")
	
	if start_drawing_line:
		if event.is_action_pressed("Grab"):
			Transitioned.emit(self, throw_state)

func state_physics_process(_delta) -> void:
	if start_drawing_line:
		set_trajectory_line()
	character.velocity = input_vector * speed
	character.move_and_slide()

func on_exit() -> void:
	disable_trajectory_line()
