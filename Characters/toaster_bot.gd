extends CharacterBody2D

class_name Enemy

signal EnemyStunned(enemy: CharacterBody2D)
signal EnemyGrabbed(enemy: CharacterBody2D)
signal EnemyThrown(enemy: CharacterBody2D)

@onready var stun_timer: Timer = $StunTimer
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var sprite_shader: ShaderMaterial = animated_sprite_2d.material
@onready var stun_shader_timer: Timer = $StunShaderTimer
@onready var grabbed_sfx: AudioStreamPlayer2D = $GrabbedSFX

var stun_shader_toggle: bool = false

var max_health: int = 30
var current_health: int = 0

var throw_damage: int = 0

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
	EnemyGrabbed.connect(_on_grabbed)
	EnemyThrown.connect(_on_thrown)
	
	stun_timer.wait_time = 3
	
	current_health = max_health

func _physics_process(delta: float) -> void:
	if is_grabbed:
		return
	
	if is_stunned:
		return
	
	if not is_on_floor():
		velocity += delta * get_gravity() * 1.3
	
	if is_thrown:
		var collision = move_and_collide(velocity * delta)
		if collision:
			#Add bounce
			var collision_normal = collision.get_normal()
			velocity = velocity.bounce(collision_normal)
			velocity *= 0.1
			
			#to prevent sliding early, turn off is_thrown after we hit floor
			if is_on_floor_only():
				is_thrown = false
	else: 
		move_and_slide()
		
	
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
	stun_timer.start()
	enable_stun_shader(true)
	
	#enable the timer that triggers flashing shader on and off
	stun_shader_timer.start()
	stun_shader_timer.one_shot = false

func _on_grabbed(enemy: CharacterBody2D) -> void:
	is_stunned = false
	is_thrown = false
	stun_timer.stop()
	enable_stun_shader(false)
	rotation_degrees += 90
	grabbed_sfx.playing = true
	#var grab_tween = get_tree().create_tween()
	#grab_tween.tween_property()
	#await grab_tween.finished
	
	
func _on_thrown(enemy: CharacterBody2D) -> void:
	is_stunned = false
	is_grabbed = false
	stun_timer.stop()
	enable_stun_shader(false)
	
	#var throw_strength = calculate_throw_strength()
	
	


func enable_stun_shader(enable: bool) -> void:
	if enable:
		sprite_shader.set_shader_parameter("flash_strength", 0.4)
	else:
		sprite_shader.set_shader_parameter("flash_strength", 1)
	
	

func can_kill(damage_amount: int) -> bool: 
	if damage_amount >= current_health:
		return true
	else:
		return false

func die() -> void: 
	print("I, ", self, "died")
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


func _on_hit_box_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemy"):
		if body.can_kill(throw_damage):
			body.die()
		else:
			print("Not enough mf!")
