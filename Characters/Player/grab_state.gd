extends State

@export var move_state: State
@export var throw_state: State

@onready var enemy_detector: Area2D = $"../../EnemyDetector"

var input_vector:= Vector2.ZERO
var speed: int = 300

func on_enter() -> void:
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
	tween.tween_property(enemy, "position",  Vector2.ZERO, 0.5).set_trans(Tween.TRANS_EXPO)
	await tween.finished


func _unhandled_input(event: InputEvent) -> void:
	input_vector = Input.get_vector("Left", "Right", "Up", "Down")
	
	if event.is_action_pressed("Grab"):
		Transitioned.emit(self, throw_state)

func state_physics_process(delta) -> void:
	character.velocity = input_vector * speed
	character.move_and_slide()
