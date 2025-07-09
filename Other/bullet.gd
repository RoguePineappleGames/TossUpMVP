extends Area2D

class_name Bullet

@onready var expiry_timer: Timer = $ExpiryTimer

var direction_vector:= Vector2.ZERO
var damage: float = 1
var speed: int = 220

func _physics_process(delta: float) -> void:
	global_position += speed * direction_vector * delta

func spawn(spawn_coordinates: Vector2, shooting_direction: Vector2 ) -> void:
	global_position = spawn_coordinates
	direction_vector = shooting_direction
	expiry_timer.start()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.take_damage(damage)
	
	queue_free()

func _on_expiry_timer_timeout() -> void:
	queue_free()
