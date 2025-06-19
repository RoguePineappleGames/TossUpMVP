extends State

class_name GrabbedState

@export var thrown_state: State

@onready var grabbed_sfx: AudioStreamPlayer2D = $GrabbedSFX

func on_enter() -> void:
	grabbed_sfx.playing = true
	character.is_grabbed = true
	character.connect("EnemyThrown", _on_enemy_thrown)

func state_process(_delta) -> void:
	character.move_and_slide()

func _on_enemy_thrown(_character: CharacterBody2D) -> void: 
	Transitioned.emit(self, thrown_state)
	character.is_grabbed = false

func on_exit() -> void:
	character.disconnect("EnemyThrown", _on_enemy_thrown)
