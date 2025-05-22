extends Area2D

@onready var expiry_timer: Timer = $ExpiryTimer

var direction: int = 1
var damage: int = 1
var speed: int = 220

func _physics_process(delta: float) -> void:
	global_position.x += speed * direction * delta

func spawn(spawn_coordinates: Vector2, shooting_direction: int ) -> void:
	global_position = spawn_coordinates
	direction = shooting_direction
	expiry_timer.start()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.adjust_health(-damage)
	
	queue_free()

func _on_expiry_timer_timeout() -> void:
	queue_free()
