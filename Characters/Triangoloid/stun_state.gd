extends StunState

const ESCAPE_SPEED: int = 100

@onready var escape_timer: Timer = $EscapeTimer

var begin_escape: bool = false

func on_enter() -> void:
	super()
	escape_timer.start()

func state_physics_process(_delta):
	update_orientation()
	if not begin_escape:
		return
	
	var receding_direction_vector = -(return_player_direction_vector())
	character.velocity = ESCAPE_SPEED * receding_direction_vector
	character.move_and_slide()


func update_orientation() -> void: 
	var angle_to_player: float = return_player_direction_vector().angle()
	var offset: float = PI/2
	##offset needed to make tip of triangle point at player
	character.rotation = angle_to_player + offset
	

func return_player_direction_vector(offset:= Vector2.ZERO) -> Vector2:
	if character.player:
		var player_position = character.player.global_position + offset
		return character.global_position.direction_to(player_position) 
	else:
		return Vector2.ZERO


func _on_escape_timer_timeout() -> void:
	begin_escape = true
