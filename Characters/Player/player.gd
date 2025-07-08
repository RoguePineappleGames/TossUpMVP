extends CharacterBody2D

signal PlayerHit()
signal PlayerDied
signal ExceptionalTransition

@onready var health_bar: TextureProgressBar = $HealthBar
@onready var state_label: Label = $StateLabel
@onready var state_machine: Node = $StateMachine
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var dash_collision_shape: CollisionPolygon2D = $DashCollisionArea/DashCollisionShape

@onready var dash_cooldown_timer: Timer = $StateMachine/DashState/DashCooldownTimer




var max_health: float = 10
var current_health: float = 0
var grabbed_enemy: Enemy = null

func _ready() -> void:
	current_health = max_health
	#health_bar.max_value = max_health
	#health_bar.value = current_health
	dash_collision_shape.set_deferred("disabled", true)

func _physics_process(_delta: float) -> void:
	state_label.text = str(state_machine.current_state)

func return_remaining_dash_cooldown() -> float:
	return dash_cooldown_timer.time_left

func adjust_health(amount: float) -> void:
	##positive amount value for healing; negative amount value for taking damage
	current_health += amount
	current_health = clamp(current_health, 0, max_health)
	if amount < 0:
		PlayerHit.emit()
	if current_health <= 0:
		die()
		
func die() -> void: 
	print("I, the player, have died")
	PlayerDied.emit()
	##Death Animation
	##Death Sound
	queue_free()
