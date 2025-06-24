extends RayCast2D

signal Collided(collider: Object)
signal LaserShutdown
@export var laser_color: Color

@onready var line_2d: Line2D = $Line2D

var beam_target := Vector2.ZERO
var cast_speed: int = 2500
var shut_down_speed: int = 1500
var shut_laser_down: bool = false


func _ready() -> void:
	enabled = false
	target_position = Vector2.ZERO
	line_2d.add_point(Vector2.ZERO, 1)
	line_2d.add_point(Vector2.ZERO, 2)
	line_2d.modulate = laser_color
	

func _physics_process(delta: float) -> void:
	if not enabled:
		return
	if shut_laser_down:
		disable_laser(delta)
	else:
		fire_laser(delta)
		
	check_for_collisions()


func change_line_endpoint(new_endpoint: Vector2) -> void:
	line_2d.set_point_position(1, new_endpoint)
	
func check_for_collisions() -> void:
	force_raycast_update()
	if is_colliding():
		var collision_point: Vector2 = to_local(get_collision_point())
		change_line_endpoint(collision_point)
		Collided.emit(get_collider())

func fire_laser(delta: float) -> void:
	target_position = target_position.move_toward(beam_target, cast_speed * delta)
	change_line_endpoint(target_position)

func disable_laser(delta: float) -> void:
	target_position = target_position.move_toward(Vector2.ZERO, shut_down_speed * delta)
	change_line_endpoint(target_position)
	if target_position == Vector2.ZERO:
		LaserShutdown.emit()
