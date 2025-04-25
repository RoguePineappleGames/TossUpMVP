extends CharacterBody2D

class_name Enemy

signal EnemyStunned(enemy: CharacterBody2D)
signal EnemyGrabbed(enemy: CharacterBody2D)
signal EnemyThrown(enemy: CharacterBody2D)

var is_stunned:
	set(new_value):
		is_stunned = new_value
		if is_stunned:
			EnemyStunned.emit(self)
	get:
		return is_stunned
		
var is_grabbed: 
	set(new_value):
		#if we want to set is_grabbed to true, check first if we are stunned. If new_value is false, immediately set is_grabbed
		#if new_value:
			##print("Is stunned is true")
			#if is_stunned:
				#is_grabbed = new_value
				#EnemyGrabbed.emit(self)
			#else:
				#is_grabbed = false
		#else:
			#is_grabbed = new_value
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
	is_grabbed = false
	is_thrown = false
	EnemyStunned.connect(_on_stunned)
	EnemyGrabbed.connect(_on_grabbed)
	EnemyThrown.connect(_on_thrown)
	
	
	
func _physics_process(delta: float) -> void:
	if is_grabbed:
		return
	
	if is_stunned:
		pass
	
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
		
	

func _on_grabbed(enemy: CharacterBody2D) -> void:

	rotation_degrees += 90

func _on_thrown(enemy: CharacterBody2D) -> void:
	is_stunned = false
	
func _on_stunned(enemy: CharacterBody2D) -> void:
	print("I'm now stunned")
