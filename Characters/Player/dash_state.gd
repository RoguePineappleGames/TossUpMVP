extends State

@export var move_state: State

@onready var dash_cooldown_timer: Timer = $DashCooldownTimer
@onready var dash_duration_timer: Timer = $DashDurationTimer
@onready var dash_ghost_life_timer: Timer = $DashGhostLifeTimer
@onready var dash_ghost_scene: PackedScene = preload("res://Other/ghost.tscn")

@onready var dash_sfx: AudioStreamPlayer2D = $DashSFX
@onready var dash_particles: CPUParticles2D = $"../../DashParticles"

var dash_direction:= Vector2.ZERO
var dash_force: int = 1000

func on_enter() -> void:
	if not dash_cooldown_timer.is_stopped():
		##DASH ON COOLDOWN 
		Transitioned.emit(self, move_state)
		return
	dash_duration_timer.start()
	dash_ghost_life_timer.start()
	set_dash_direction()
	adjust_collision_layers(false)
	activate_SFX()

func set_dash_direction() -> void:
	var mouse_position = character.get_global_mouse_position()
	dash_direction = character.global_position.direction_to(mouse_position)

func adjust_collision_layers(toggle: bool) -> void:
	##toggle invincibility
	character.set_collision_layer_value(2, toggle)
	##toggle dash collision shape
	character.dash_collision_shape.set_deferred("disabled", toggle)
	
func state_physics_process(_delta) -> void:
	character.velocity = dash_direction * dash_force
	character.move_and_slide()

func activate_SFX() -> void:
	##particles emit opposite of dash direction
	dash_particles.direction.x = -dash_direction.x
	dash_particles.emitting = true
	dash_sfx.playing = true

func _on_dash_collision_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemy"):
		body.stun()


func _on_dash_ghost_life_timer_timeout() -> void:
	##Keep adding dash ghosts when the timer expires
	add_dash_ghost()


func add_dash_ghost() -> void:
	var ghost_instance = dash_ghost_scene.instantiate()
	ghost_instance.set_property(character.global_position, character.scale, character.animated_sprite_2d.flip_h)
	get_tree().root.add_child(ghost_instance)


func _on_dash_duration_timer_timeout() -> void:
	dash_cooldown_timer.start()
	dash_ghost_life_timer.stop()
	adjust_collision_layers(true)
	dash_particles.emitting = false
	Transitioned.emit(self, move_state)

#func on_exit() -> void:
	#dash_cooldown_timer.start()
	#dash_ghost_life_timer.stop()
	#adjust_collision_layers(true)
