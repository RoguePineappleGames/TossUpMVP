extends State

const CHASE_SPEED: int = 100

func state_physics_process(delta):
	update_orientation()
	var direction_vector = return_player_direction_vector()

	character.velocity = CHASE_SPEED * direction_vector
	character.move_and_slide()
	
func update_orientation() -> void: 
	var angle_to_player: float = return_player_direction_vector().angle()
	var offset: float = PI/2
	##offset needed to make tip of triangle point at player
	character.rotation = angle_to_player + offset
	
func return_player_direction_vector() -> Vector2:
	var player_position = character.player.global_position
	return character.global_position.direction_to(player_position)
