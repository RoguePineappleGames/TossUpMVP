extends CharacterBody2D

signal EnemyStunned(enemy: CharacterBody2D)
signal EnemyGrabbed(enemy: CharacterBody2D)
signal EnemyThrown(enemy: CharacterBody2D)

@export var player: CharacterBody2D

@onready var physics_collision_box: CollisionShape2D = $PhysicsCollisionBox
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@onready var stun_timer: Timer = $StunTimer
@onready var stun_shader_timer: Timer = $StunShaderTimer
@onready var sprite_shader: ShaderMaterial = animated_sprite_2d.material

##Special Effects
@onready var stunned_sfx: AudioStreamPlayer2D = $SpecialEffects/StunnedSFX
@onready var grab_particles: CPUParticles2D = $SpecialEffects/GrabParticles
@onready var grabbed_sfx: AudioStreamPlayer2D = $SpecialEffects/GrabbedSFX
@onready var death_sfx: AudioStreamPlayer2D = $SpecialEffects/DeathSFX

@onready var idle_timer: Timer = $IdleTimer
@onready var chase_timer: Timer = $ChaseTimer

var stun_shader_toggle: bool = false

var max_health: int = 60
var current_health: int = 0

var throw_damage: int = 0
var throw_mass: float = 1

#movement
var is_idle: bool = true
var is_chasing: bool = false
var is_attacking: bool = false
var direction: int = 1
var player_direction:= Vector2.ZERO
var speed: int = 200

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
	get:
		return is_thrown

func _ready() -> void:
	is_stunned = false
	is_grabbed = false
	is_thrown = false
	EnemyStunned.connect(_on_stunned)
	#EnemyGrabbed.connect(_on_grabbed)
	#EnemyThrown.connect(_on_thrown)
	stun_timer.wait_time = 1.5
	
	current_health = max_health

func _physics_process(delta: float) -> void:
	if not is_on_floor() and not is_grabbed:
		velocity += delta * get_gravity() * 1.3
	
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
				print("We landed on the floor after being thrown")
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
		if idle_timer.is_stopped():
			idle_timer.start()
	
	elif is_chasing:
		if chase_timer.is_stopped():
			chase_timer.start()
		var player_direction = global_position.direction_to(player.global_position)
		
		if player_direction.x > 0.4:
			direction = 1
		elif player_direction.x < -0.4:
			direction = -1
		else:
			direction = 0
		#print(player_direction)
		velocity.x = speed * direction
		
		
	elif is_attacking: 
		pass
	
	update_animation()

func update_animation() -> void: 
	if direction >= 0:
		animated_sprite_2d.flip_h = false
	else:
		animated_sprite_2d.flip_h = true

	if is_idle:
		animated_sprite_2d.play("Idle")
	elif is_chasing:
		animated_sprite_2d.play("Run")
	else:
		animated_sprite_2d.play("Idle")
		
func stun() -> void:
	is_stunned = true
	print("Stunned!")

func grab() -> void: 
	is_grabbed = false
	print("I cannot be grabbed dumbass")
	
func throw(damage: int) -> void:
	throw_damage = damage * throw_mass
	is_thrown = false

func _on_stunned(_enemy: CharacterBody2D) -> void:
	print("I, ", self, " am stunned")
	is_grabbed = false
	is_thrown = false
	is_idle = true
	is_attacking = false
	is_chasing = false
	stun_timer.start()
	enable_stun_shader(true)
	stunned_sfx.playing = true
	#enable the timer that triggers flashing shader on and off
	stun_shader_timer.start()
	stun_shader_timer.one_shot = false
	

#func _on_grabbed(enemy: CharacterBody2D) -> void:
	#is_stunned = false
	#is_thrown = false
	#is_idle = false
	#is_attacking = false
	#is_walking = false
	#stun_timer.stop()
	#enable_stun_shader(false)
	#grabbed_sfx.playing = true
	#grab_particles.emitting = true
	#
	#physics_collision_box.set_deferred("disabled", true)

#func _on_thrown(enemy: CharacterBody2D) -> void:
	#is_stunned = false
	#is_grabbed = false
	#is_idle = false
	#is_attacking = false
	#is_walking = false
	#stun_timer.stop()
	#enable_stun_shader(false)
	#physics_collision_box.set_deferred("disabled", false)

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

func _on_throw_hit_box_area_entered(area: Area2D) -> void:
	if is_thrown:
		if area.is_in_group("ThrownEnemy"):
			var enemy = area.get_parent()
			#print("I, ", self, "can be thrown")
			if enemy.can_be_killed(throw_damage):
				enemy.die()
			else:
				print("Not enough mf!")


func _on_idle_timer_timeout() -> void:
	is_idle = false
	is_chasing = true


func _on_chase_timer_timeout() -> void:
	is_idle = true
	is_chasing = false
