extends CharacterBody2D

class_name Enemy

signal EnemyStunned(enemy: CharacterBody2D)
signal EnemyGrabbed(enemy: CharacterBody2D)
signal EnemyThrown(enemy: CharacterBody2D)

const bullet_path = preload("res://Other/bullet.tscn")
@onready var bullet_spawn_position: Marker2D = $BulletSpawnPosition

@onready var stun_timer: Timer = $StunTimer
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var sprite_shader: ShaderMaterial = animated_sprite_2d.material
@onready var stun_shader_timer: Timer = $StunShaderTimer

@onready var grab_particles: CPUParticles2D = $SpecialEffects/GrabParticles
@onready var grabbed_sfx: AudioStreamPlayer2D = $SpecialEffects/GrabbedSFX
@onready var stunned_sfx: AudioStreamPlayer2D = $SpecialEffects/StunnedSFX
@onready var death_sfx: AudioStreamPlayer2D = $SpecialEffects/DeathSFX


@onready var idle_timer: Timer = $IdleTimer

@onready var movement_ray_cast: RayCast2D = $MovementRayCast
@onready var attack_ray_cast: RayCast2D = $AttackRayCast


var stun_shader_toggle: bool = false

var max_health: int = 30
var current_health: int = 0

var throw_damage: int = 0

var is_attacking: bool = false
var is_idle: bool = true

var is_walking: bool = false
var direction: int = 1
var speed: int = 100
var movement_ray_cast_length: int = 20
var attack_ray_cast_length: int = 40


var is_stunned:
	set(new_value):
		is_stunned = new_value
		if is_stunned:
			EnemyStunned.emit(self)
	get:
		return is_stunned
		
var is_grabbed: 
	set(new_value):
		is_grabbed = new_value
		if is_grabbed:
			EnemyGrabbed.emit(self)
	get:
		return is_grabbed

var is_thrown:
	set(new_value):
		is_thrown = new_value
		if is_thrown:
			EnemyThrown.emit(self)
		else:
			is_idle = true
	get:
		return is_thrown

func _ready() -> void:
	is_stunned = false
	is_grabbed = false
	is_thrown = false
	EnemyStunned.connect(_on_stunned)
	EnemyGrabbed.connect(_on_grabbed)
	EnemyThrown.connect(_on_thrown)
	stun_timer.wait_time = 3
	
	current_health = max_health

func _physics_process(delta: float) -> void:
	#if not is_on_floor() and not is_grabbed:
		#velocity += delta * get_gravity() * 1.3
	
	if is_grabbed:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	elif is_stunned:
		velocity = Vector2.ZERO
		return
	elif is_thrown:
		var collision = move_and_collide(velocity * delta)
		if collision:
			#Add bounce
			var collision_normal = collision.get_normal()
			#print(collision_normal)
			velocity = velocity.bounce(collision_normal)
			velocity *= 0.1
			##is on_floor_only is too slow here, so we check if the collision normal is facing vertically up
			if collision_normal.y < -0.7:
				#print("We landed on the floor after being thrown")
				is_thrown = false
				velocity = Vector2.ZERO
	else:
		move_and_slide()
	
	#to prevent sliding early, turn off is_thrown after we hit floor
	#if is_on_floor_only():
		#print("We landed on the floor after being thrown")
		#is_thrown = false
		#velocity = Vector2.ZERO
	
	if is_idle:
		##Idle for x amount of seconds then start walking
		velocity.x = 0
		if idle_timer.is_stopped():
			idle_timer.start()
	
	elif is_walking:
		##Set velocity to speed * direction and start checking both colliders. 
		##If movement collider collides, flip direction and ray cast directions
		##IF attack collider collides, go into attack mode
		velocity.x = speed * direction
		if movement_ray_cast.is_colliding():
			direction *= -1
			movement_ray_cast.target_position *= -1
			attack_ray_cast.target_position *= -1
			bullet_spawn_position.position.x *= -1
			#print(direction)
		elif attack_ray_cast.is_colliding():
			is_attacking = true
			is_walking = false
	
	elif is_attacking:
		print("ATTACK MF")
		velocity.x = 0
		shoot_bullet()
		is_attacking = false
		is_idle = true
	
	update_animation()
	#move_and_slide()

func update_animation() -> void: 
	if direction >= 0:
		animated_sprite_2d.flip_h = false
	else:
		animated_sprite_2d.flip_h = true

	if is_idle:
		animated_sprite_2d.play("Idle")
	
func stun() -> void:
	is_stunned = true
	
func grab() -> void:
	is_grabbed = true

func throw(damage: int) -> void:
	throw_damage = damage
	is_thrown = true

func _on_stunned(enemy: CharacterBody2D) -> void:
	is_grabbed = false
	is_thrown = false
	is_idle = false
	is_attacking = false
	is_walking = false
	stun_timer.start()
	enable_stun_shader(true)
	stunned_sfx.playing = true
	#enable the timer that triggers flashing shader on and off
	stun_shader_timer.start()
	stun_shader_timer.one_shot = false

func _on_grabbed(enemy: CharacterBody2D) -> void:
	is_stunned = false
	is_thrown = false
	is_idle = false
	is_attacking = false
	is_walking = false
	stun_timer.stop()
	enable_stun_shader(false)
	#rotation_degrees += 90
	#print("Grabbing")
	grabbed_sfx.playing = true
	grab_particles.emitting = true

func _on_thrown(enemy: CharacterBody2D) -> void:
	is_stunned = false
	is_grabbed = false
	is_idle = false
	is_attacking = false
	is_walking = false
	stun_timer.stop()
	enable_stun_shader(false)

func enable_stun_shader(enable: bool) -> void:
	if enable:
		sprite_shader.set_shader_parameter("flash_strength", 0.4)
	else:
		sprite_shader.set_shader_parameter("flash_strength", 1)

func can_be_killed(damage_amount: int) -> bool: 
	if damage_amount >= current_health:
		print("Can kill with ", damage_amount)
		return true
	else:
		print("Cannot kill")
		return false

func die() -> void: 
	print("I, ", self, "died")
	death_sfx.playing = true
	await death_sfx.finished
	queue_free()

func _on_stun_timer_timeout() -> void:
	is_stunned = false
	enable_stun_shader(false)
	#disable the repeating timer for the flashing
	stun_shader_timer.one_shot = true

func _on_stun_shader_timer_timeout() -> void:
	if is_stunned:
		enable_stun_shader(stun_shader_toggle)
		stun_shader_toggle = !stun_shader_toggle

func _on_hit_box_area_entered(area: Area2D) -> void:
	if is_thrown:
		if area.is_in_group("ThrownEnemy"):
			var enemy = area.get_parent()
			#print("I, ", self, "can be thrown")
			if enemy.can_be_killed(throw_damage):
				enemy.die()
			else:
				print("Not enough mf!")

func _on_idle_timer_timeout() -> void:
	#print("Idle timer is done!")
	is_idle = false
	is_walking = true

func shoot_bullet() -> void:
	var bullet_scene = bullet_path.instantiate()
	get_tree().root.add_child(bullet_scene)
	bullet_scene.spawn(bullet_spawn_position.global_position, direction)
	
