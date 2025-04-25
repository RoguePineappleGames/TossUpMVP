extends Node2D
@onready var aiming_crosshair: Sprite2D = $AimingCrosshair
@onready var camera_2d: Camera2D = $Camera2D

#func _ready() -> void:
	##camera_2d.global_position = display/"size/viewport_width"
##"size/viewport_height"
func _physics_process(delta: float) -> void:
	aiming_crosshair.global_position = get_global_mouse_position()
