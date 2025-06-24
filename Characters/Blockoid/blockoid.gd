extends Enemy

@export var player: CharacterBody2D

@onready var timeout_timer_area_1: Timer = $DashingArea1/TimeoutTimerArea1
@onready var timeout_timer_area_2: Timer = $DashingArea2/TimeoutTimerArea2

var player_entered_dashingarea1: bool = false
var player_exitted_dashingarea1: bool = false
var player_entered_dashingarea2: bool = false
var player_exitted_dashingarea2: bool = false

func stun() -> void:
	pass


func _physics_process(delta: float) -> void:
	super(delta)
	if player_entered_dashingarea1 and player_entered_dashingarea2:
		ExceptionalTransition.emit(state_machine.current_state, stun_state)
		EnemyStunned.emit(self)
		player_entered_dashingarea1 = false
		player_entered_dashingarea2 = false


func _on_dashing_area_1_area_entered(area: Area2D) -> void:
	player_entered_dashingarea1 = true
	print("Entered area 1")
	timeout_timer_area_1.start()


func _on_dashing_area_2_area_entered(area: Area2D) -> void:
	player_entered_dashingarea2 = true
	print("Entered area 2")
	timeout_timer_area_2.start()


func _on_timeout_timer_area_1_timeout() -> void:
	player_entered_dashingarea1 = false
	print("Area 1 timeout")


func _on_timeout_timer_area_2_timeout() -> void:
	player_entered_dashingarea2 = false
	print("Area 2 timeout")
