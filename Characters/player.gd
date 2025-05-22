extends PlatformerController2D

signal DashEnded
signal PlayerDied

@export var charge_time: float = 3
@export var dash_ghost_scene: PackedScene

@onready var physics_collision_shape_2d: CollisionShape2D = $PhysicsCollisionShape2D
@onready var dash_collision_shape: CollisionShape2D = $DashCollisionArea/DashCollisionShape

#2 guns just to handle turning right and left
@onready var grabber_gun_r: Area2D = $GrabberGun_R
@onready var grabber_gun_l: Area2D = $GrabberGun_L

@onready var charged_shot_timer: Timer = $ChargedShotTimer
@onready var charging_progress_indicator: TextureProgressBar = $ChargingProgressIndicator

@onready var dash_cooldown_timer: Timer = $DashCooldownTimer
@onready var dash_duration_timer: Timer = $DashDurationTimer
@onready var dash_ghost_life_timer: Timer = $DashGhostLifeTimer
@onready var dash_particles: CPUParticles2D = $DashParticles
@onready var dash_sfx: AudioStreamPlayer2D = $DashSFX

#var wants_to_dash: bool = false
var is_dashing: bool = false
var dash_force: int = 2000
var dash_friction: int = 0.1

var max_health: int = 3
var current_health: int = 0

var active_gun: 
	set(new_value):
		#if there is already an active gun, disable it
		#Set grabbed enemy and has_enemy when changing active gun
		if active_gun:
			new_value.has_enemy = active_gun.has_enemy
			new_value.grabbed_enemy = active_gun.grabbed_enemy
			active_gun.visible = false
		#set active gun to new gun, then enable it
		active_gun = new_value
		active_gun.visible = true
		
	get:
		return active_gun

func _ready() -> void:
	charging_progress_indicator.visible = false
	grabber_gun_r.visible = false
	grabber_gun_l.visible = false
	dash_collision_shape.set_deferred("disabled", true)
	DashEnded.connect(_on_dash_end)
	charged_shot_timer.wait_time = charge_time
	current_health = max_health
	super._ready()
	

func _physics_process(delta):
	if is_coyote_timer_running() or current_jump_type == JumpType.NONE:
		jumps_left = max_jump_amount
	if is_feet_on_ground() and current_jump_type == JumpType.NONE:
		start_coyote_timer()
		
	# Check if we just hit the ground this frame
	if not _was_on_ground and is_feet_on_ground():
		current_jump_type = JumpType.NONE
		if is_jump_buffer_timer_running() and not can_hold_jump: 
			jump()
		
		hit_ground.emit()
	
	# Cannot do this in _input because it needs to be checked every frame
	if Input.is_action_pressed(input_jump):
		if can_ground_jump() and can_hold_jump:
			jump()
	
	var gravity = apply_gravity_multipliers_to(default_gravity)
	#acc.y = gravity
	
	# Apply friction
	velocity.x *= 1 / (1 + (delta * friction))
	velocity += acc * delta
	
	_was_on_ground = is_feet_on_ground()
	
	if not charged_shot_timer.is_stopped():
		charging_progress_indicator.value = remap((charged_shot_timer.wait_time - charged_shot_timer.time_left), 0, charged_shot_timer.wait_time, 0, 100)
	
	if is_dashing:
		velocity.x *= 1/(1 + (delta * dash_friction))
		#velocity.y *= 1/(1 + (delta * dash_friction))

	update_animation()
	move_and_slide()

func update_animation() -> void:
		
	if acc.x == 0:
		animated_sprite_2d.play("Idle")

	elif acc.x > 0:
		if !is_dashing:
			animated_sprite_2d.play("Walk")
		animated_sprite_2d.flip_h = false
		active_gun = grabber_gun_r

	elif acc.x < 0:
		if !is_dashing:
			animated_sprite_2d.play("Walk")
		animated_sprite_2d.flip_h = true
		active_gun = grabber_gun_l
	
	#if not charged_shot_timer.is_stopped():
		#animated_sprite_2d.play("Charging")
	#
	#elif is_dashing:
		#animated_sprite_2d.play("Dash")
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Dash"):
		#wants_to_dash = true
		dash()
		
	elif event.is_action_pressed("Grab"):
		if not active_gun:
			return
		
		if not active_gun.has_enemy:
			var grabbed_enemy = active_gun.scan_and_grab()
			if grabbed_enemy:
				charged_shot_timer.start()
				charging_progress_indicator.visible = true
			
			
			
	elif event.is_action_released("Grab"):
		if not active_gun:
			return
			
		if active_gun.has_enemy:
			active_gun.shoot(charged_shot_timer.time_left, charged_shot_timer.wait_time)
			charged_shot_timer.stop()
			charging_progress_indicator.visible = false

func dash() -> void:
	if not dash_cooldown_timer.is_stopped():
		print("Cooling Down..")
		return
	is_dashing = true
	dash_duration_timer.start()
	dash_ghost_life_timer.start()
	
	var aimed_direction:= Vector2.ZERO
	if animated_sprite_2d.flip_h == true:
		aimed_direction.x = -1
	else:
		aimed_direction.x = +1
	
	velocity = aimed_direction * dash_force
	set_collision_mask_value(3, false)
	dash_collision_shape.set_deferred("disabled", false)
	
	#particles emit opposite of dash direction
	dash_particles.direction.x = -aimed_direction.x
	dash_particles.emitting = true
	dash_sfx.playing = true

func _on_dash_duration_timer_timeout() -> void:
	_on_dash_end()
	#DashEnded.emit()

func _on_dash_end() -> void:
	is_dashing = false
	set_collision_mask_value(3, true)
	dash_collision_shape.set_deferred("disabled", true)
	dash_particles.emitting = false
	dash_cooldown_timer.start()
	dash_ghost_life_timer.stop()

func _on_dash_ghost_life_timer_timeout() -> void:
	#Keep adding dash ghosts when the timer expires
	add_dash_ghost()

func add_dash_ghost() -> void:
	var ghost_instance = dash_ghost_scene.instantiate()
	ghost_instance.set_property(position, scale, animated_sprite_2d.flip_h)
	get_tree().current_scene.add_child(ghost_instance)

func _on_dash_collision_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemy"):
		body.stun()

func adjust_health(amount: int) -> void:
	#positive amount value for healing
	#negative amount value for taking damage
	current_health += amount
	print("Health changed by ", amount)
	current_health = clamp(current_health, 0, max_health)
	
	if current_health <= 0:
		die()
		
func die() -> void: 
	print("I, the player, have died")
	PlayerDied.emit()
	##Death Animation
	##Death Sound
	queue_free()
