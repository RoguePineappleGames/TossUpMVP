extends CharacterBody2D

signal DashEnded
signal PlayerDied

@export var charge_time: float = 3
@export var dash_ghost_scene: PackedScene
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@onready var physics_collision_shape_2d: CollisionShape2D = $PhysicsCollisionShape2D
@onready var dash_collision_shape: CollisionPolygon2D = $DashCollisionArea/DashCollisionShape

#2 guns just to handle turning right and left
@onready var grabber_gun_r: Area2D = $GrabberGun_R
@onready var grabber_gun_l: Area2D = $GrabberGun_L

@onready var charged_shot_timer: Timer = $ChargedShotTimer
@onready var charging_progress_indicator: TextureProgressBar = $ChargingProgressIndicator
@onready var health_bar: TextureProgressBar = $HealthBar

@onready var dash_cooldown_timer: Timer = $DashCooldownTimer
@onready var dash_duration_timer: Timer = $DashDurationTimer
@onready var dash_ghost_life_timer: Timer = $DashGhostLifeTimer
@onready var dash_particles: CPUParticles2D = $DashParticles
@onready var dash_sfx: AudioStreamPlayer2D = $DashSFX


var input_vector: Vector2
var speed = 300

var is_dashing: bool = false
var dash_force: int = 1000
var dash_friction: float = 0.1
var dash_direction

var max_health: int = 10
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
	health_bar.max_value = max_health
	health_bar.value = current_health
	

func _physics_process(_delta):
	#acc.y = gravity
	
	if not charged_shot_timer.is_stopped():
		charging_progress_indicator.value = remap((charged_shot_timer.wait_time - charged_shot_timer.time_left), 0, charged_shot_timer.wait_time, 0, 100)
	
	if is_dashing:
		velocity = dash_direction * dash_force
		#velocity.x *= 1/(1 + (delta * dash_friction))
		#velocity.y *= 1/(1 + (delta * dash_friction))
	else:
		velocity = input_vector * speed
	
	update_animation()
	move_and_slide()

func update_animation() -> void:
		
	if velocity.x == 0:
		animated_sprite_2d.play("Idle")

	elif velocity.x > 0:
		#if !is_dashing:
			#animated_sprite_2d.play("Walk")
		#animated_sprite_2d.flip_h = false
		active_gun = grabber_gun_r

	elif velocity.x < 0:
		#if !is_dashing:
			#animated_sprite_2d.play("Walk")
		#animated_sprite_2d.flip_h = true
		active_gun = grabber_gun_l

func _unhandled_input(event: InputEvent) -> void:
	input_vector = Input.get_vector("Left", "Right", "Up", "Down")
	
	if event.is_action_pressed("Dash"):
		dash()
	if event.is_action_pressed("Grab"):
		print("Current gun: ", active_gun)
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
	
	var mouse_position = get_global_mouse_position()
	print("We are pointing here: ", mouse_position)
	dash_direction = global_position.direction_to(mouse_position)
	print("We should dash to: ", dash_direction)

	#set_collision_mask_value(3, false)
	dash_collision_shape.set_deferred("disabled", false)
	
	#particles emit opposite of dash direction
	dash_particles.direction.x = -dash_direction.x
	dash_particles.emitting = true
	dash_sfx.playing = true

func _on_dash_duration_timer_timeout() -> void:
	_on_dash_end()
	#DashEnded.emit()

func _on_dash_end() -> void:
	is_dashing = false
	#set_collision_mask_value(3, true)
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
	##positive amount value for healing; negative amount value for taking damage
	current_health += amount
	print("Health changed by ", amount)
	current_health = clamp(current_health, 0, max_health)
	health_bar.value = current_health
	if current_health <= 0:
		die()
		
func die() -> void: 
	print("I, the player, have died")
	PlayerDied.emit()
	##Death Animation
	##Death Sound
	queue_free()
