extends Camera2D

@onready var shake_timer: Timer = $ShakeTimer

var temp: float
var shake_screen: bool = false
var shake_screen_strength: float = 3.0
var shake_fade: float = 5.0
var rng = RandomNumberGenerator.new()

func _physics_process(delta: float) -> void:
	if shake_screen and not shake_timer.is_stopped():
		shake_screen_strength = lerpf(shake_screen_strength, 0, shake_fade * delta)
		offset = Vector2.ONE * rng.randf_range(-shake_screen_strength, shake_screen_strength)

func activate_screen_shake(strength: float, fade: float):
	shake_screen = true
	shake_timer.start()
	shake_screen_strength = strength
	shake_fade = fade
	
func _on_shake_timer_timeout() -> void:
	shake_screen = false
	shake_screen_strength = 3
	
