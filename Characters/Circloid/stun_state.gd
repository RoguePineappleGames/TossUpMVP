extends State

@export var idle_state: State
@export var grabbed_state: State


@onready var stun_timer: Timer = $StunTimer
@onready var stun_shader_timer: Timer = $StunShaderTimer
@onready var stunned_sfx: AudioStreamPlayer2D = $StunnedSFX

var stun_shader_toggle: bool = false

func on_enter():
	character.velocity = Vector2.ZERO
	character.is_stunned = true
	stun_timer.start()
	stun_shader_timer.start()
	stun_shader_timer.one_shot = false
	enable_stun_shader(true)
	stunned_sfx.playing = true
	##Connect the EnemyGrabbed signal
	character.connect("EnemyGrabbed", _on_enemy_grabbed)

func enable_stun_shader(enable: bool) -> void:
	if enable:
		character.sprite_shader.set_shader_parameter("flash_strength", 0.4)
	else:
		character.sprite_shader.set_shader_parameter("flash_strength", 1)

func _on_stun_shader_timer_timeout() -> void:
	enable_stun_shader(stun_shader_toggle)
	stun_shader_toggle = !stun_shader_toggle

func _on_stun_timer_timeout() -> void:
	Transitioned.emit(self, idle_state)

func _on_enemy_grabbed(_character: CharacterBody2D) -> void:
	Transitioned.emit(self, grabbed_state)

func on_exit():
	character.disconnect("EnemyGrabbed", _on_enemy_grabbed)
	character.is_stunned = false
	
	stun_timer.stop()
	stun_shader_timer.stop()
	stun_shader_timer.one_shot = true
	enable_stun_shader(false)
