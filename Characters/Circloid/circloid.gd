extends CharacterBody2D

signal EnemyStunned(enemy: CharacterBody2D)
signal EnemyGrabbed(enemy: CharacterBody2D)
signal EnemyThrown(enemy: CharacterBody2D)



@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var sprite_shader: ShaderMaterial = animated_sprite_2d.material
@onready var state_machine: CharacterStateMachine = $StateMachine
@onready var state_label: Label = $StateLabel


##Timer nodes
@onready var stun_timer: Timer = $Timers/StunTimer
@onready var stun_shader_timer: Timer = $Timers/StunShaderTimer

##Special Effect nodes
@onready var grabbed_sfx: AudioStreamPlayer2D = $SpecialEffects/GrabbedSFX
@onready var stunned_sfx: AudioStreamPlayer2D = $SpecialEffects/StunnedSFX
@onready var death_sfx: AudioStreamPlayer2D = $SpecialEffects/DeathSFX


var stun_shader_toggle: bool = false

var throw_damage: int = 0

var is_attacking: bool = false
var is_idle: bool = true

var is_walking: bool = false
var direction:= Vector2.ZERO
var speed: int = 150

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
	

func _physics_process(delta: float) -> void:
	state_label.text = str(state_machine.current_state.name)

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
	grabbed_sfx.playing = true

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
