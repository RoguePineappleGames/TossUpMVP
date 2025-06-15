extends CharacterBody2D

signal EnemyStunned(enemy: CharacterBody2D)
signal EnemyGrabbed(enemy: CharacterBody2D)
signal EnemyThrown(enemy: CharacterBody2D)
signal ExceptionalTransition

@export var stun_state: State


@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var sprite_shader: ShaderMaterial = animated_sprite_2d.material
@onready var state_machine: CharacterStateMachine = $StateMachine
@onready var state_label: Label = $StateLabel

@onready var death_sfx: AudioStreamPlayer2D = $SpecialEffects/DeathSFX

var throw_damage: int = 0

var direction:= Vector2.ZERO
var speed: int = 150

var is_stunned: bool = false
var is_grabbed: bool = false
var is_thrown: bool = false

func _physics_process(_delta: float) -> void:
	state_label.text = str(state_machine.current_state.name)
	move_and_slide()

func stun() -> void:
	print("Yo we stunned")
	ExceptionalTransition.emit(state_machine.current_state, stun_state)
	EnemyStunned.emit(self)
	
func grab() -> void:
	print("We are grabbed")
	EnemyGrabbed.emit(self)

func throw(damage: int) -> void:
	throw_damage = damage
	EnemyThrown.emit(self)
