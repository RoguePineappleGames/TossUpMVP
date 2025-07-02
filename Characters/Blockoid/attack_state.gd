extends State

const LASER_DAMAGE: int = 2

@export var idle_state: State

@onready var laser_beam: RayCast2D = $"../../LaserBeam"
@onready var laser_shutdown_timer: Timer = $LaserShutdownTimer


func on_enter() -> void:
	var beam_target: Vector2 = return_beam_target()
	laser_beam.beam_target = beam_target
	laser_beam.enabled = true
	laser_beam.connect("Collided", _on_laser_beam_collision)
	laser_beam.connect("LaserShutdown", _on_laser_beam_shutdown)
	laser_shutdown_timer.start()
	
func return_beam_target() -> Vector2:
	if character.player:
		var distance = character.player.global_position - character.global_position 
		return distance
	else:
		return Vector2.ZERO

func on_exit() -> void:
	laser_beam.disconnect("Collided", _on_laser_beam_collision)
	laser_beam.disconnect("LaserShutdown", _on_laser_beam_shutdown)
	
func _on_laser_beam_collision(collider: Object) -> void:
	if collider.is_in_group("Player"):
		collider.adjust_health(-LASER_DAMAGE)

func _on_laser_beam_shutdown() -> void:
	laser_beam.shut_laser_down = false
	laser_beam.enabled = false
	Transitioned.emit(self, idle_state)

func _on_laser_shutdown_timer_timeout() -> void:
	laser_beam.shut_laser_down = true
