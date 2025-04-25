extends Node2D
@onready var aiming_crosshair: Sprite2D = $AimingCrosshair

func _physics_process(delta: float) -> void:
	aiming_crosshair.global_position = get_global_mouse_position()
