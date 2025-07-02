extends State

const CHASE_SPEED: int = 120

@export var attack_state: State

var rng = RandomNumberGenerator.new()

##In an effort to prevent different triangoloids from bunching up when chasing the player, we add an offset to the position they are chasing
var randomized_offset_to_player:= Vector2.ZERO

func on_enter():
	randomized_offset_to_player = Vector2(rng.randf_range(-100, 100), rng.randf_range(-100, 100) )


func state_physics_process(_delta):
	update_orientation()
	var direction_vector = return_player_direction_vector(randomized_offset_to_player)
	var new_direction = direction_vector
	character.velocity = CHASE_SPEED * new_direction
	character.move_and_slide()
	
	var distance_to_player: float = return_distance_to_player()
	if distance_to_player <= 150:
		Transitioned.emit(self, attack_state)


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

func return_distance_to_player() -> float:
	if character.player:
		var player_position = character.player.global_position
		return character.global_position.distance_to(player_position)
	else:
		return 0
