extends CharacterBody2D

signal PlayerHit
signal PlayerDied
signal ExceptionalTransition

@onready var health_bar: TextureProgressBar = $HealthBar
@onready var state_label: Label = $StateLabel
@onready var state_machine: Node = $StateMachine
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var dash_collision_shape: CollisionPolygon2D = $DashCollisionArea/DashCollisionShape



var max_health: int = 10
var current_health: int = 0
var grabbed_enemy: Enemy = null

func _ready() -> void:
	current_health = max_health
	health_bar.max_value = max_health
	health_bar.value = current_health
	dash_collision_shape.set_deferred("disabled", true)

func _physics_process(delta: float) -> void:
	state_label.text = str(state_machine.current_state)


func adjust_health(amount: int) -> void:
	##positive amount value for healing; negative amount value for taking damage
	if amount < 0:
		PlayerHit.emit()
	current_health += amount
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
