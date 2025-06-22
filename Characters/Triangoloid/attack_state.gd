extends State

const ATTACK_SPEED: int = 400
const CONTACT_DAMAGE: int = 1

@export var idle_state: State

@onready var player_detector: Area2D = $"../../PlayerDetector"

var rng = RandomNumberGenerator.new()

##In an effort to prevent different triangoloids from bunching up when chasing the player, we add an offset to the position they are chasing
#var randomized_offset_to_player:= Vector2.ZERO

var direction_vector:= Vector2.ZERO
var last_known_player_position:= Vector2.ZERO

func on_enter():
	#randomized_offset_to_player = Vector2(rng.randf_range(-50, 50), rng.randf_range(-25, 25) )
	player_detector.monitoring = true
	last_known_player_position = return_last_known_player_position()
	direction_vector = return_player_direction_vector()

func state_physics_process(_delta):
	#update_orientation()
	character.velocity = ATTACK_SPEED * direction_vector
	character.move_and_slide()
	
	var distance_to_player: float = return_distance_to_last_known_player_position()
	if distance_to_player <= 10:
		Transitioned.emit(self, idle_state)

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

func return_last_known_player_position() -> Vector2:
	if character.player:
		return character.player.global_position
	else:
		return Vector2.ZERO

func return_distance_to_last_known_player_position() -> float:
	return character.global_position.distance_to(last_known_player_position)


func _on_player_detector_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.adjust_health(-CONTACT_DAMAGE)

func on_exit() -> void:
	player_detector.monitoring = false
