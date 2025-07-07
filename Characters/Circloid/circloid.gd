extends CharacterBody2D

class_name Enemy

signal EnemyStunned(enemy: CharacterBody2D)
signal EnemyGrabbed(enemy: CharacterBody2D)
signal EnemyThrown(enemy: CharacterBody2D)
signal ExceptionalTransition
signal EnemyDied(enemy: CharacterBody2D, score: int)

enum ShapeType {CIRCLOID, TRIANGOLOID, BLOCKOID, RHOMBOID, STAROID}

const GRAB_SCALING_VALUE: float = 0.5
const THROW_SCALING_VALUE: float = 1

##for correct matchup kills
const HIGH_SCORE: int = 100
##For same-shape kills
const LOW_SCORE: int = 25

@export var shape_type: ShapeType
@export var stun_state: State
@export var death_state: State
@onready var enemy_detector: Area2D = $EnemyDetector


@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var sprite_shader: ShaderMaterial = animated_sprite_2d.material
@onready var state_machine: CharacterStateMachine = $StateMachine
@onready var state_label: Label = $StateLabel

var throw_damage: int = 0

var direction:= Vector2.ZERO
var speed: int = 150

var is_stunned: bool = false
var is_grabbed: bool = false
var is_thrown: bool = false

var death_score: int = 0

func _ready() -> void:
	enemy_detector.monitoring = false

func _physics_process(_delta: float) -> void:
	state_label.text = str(state_machine.current_state.name)
	
	##DO NOT CALL MOVE AND SLIDE HERE IT WILL FUCK UP EVERYTHING. LET THE STATE THAT NEEDS IT CALL IT
	#move_and_slide()

func stun() -> void:
	ExceptionalTransition.emit(state_machine.current_state, stun_state)
	EnemyStunned.emit(self)
	
func grab() -> void:
	EnemyGrabbed.emit(self)
	scale_enemy(GRAB_SCALING_VALUE)

func throw(damage: int = 0) -> void:
	#throw_damage = damage
	EnemyThrown.emit(self)
	scale_enemy(THROW_SCALING_VALUE)

func die(score: int) -> void: 
	death_score = score
	print("I, ", self, "died")
	ExceptionalTransition.emit(state_machine.current_state, death_state)

func scale_enemy(scaling_value: float) -> void:
	scale = Vector2(scaling_value, scaling_value)
	rotation = 0
