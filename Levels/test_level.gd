extends Node2D

signal RoomDone

@onready var enemy_container: Node = $EnemyContainer
@onready var player: CharacterBody2D = $Player


@onready var aiming_crosshair: Sprite2D = $AimingCrosshair
@onready var screen_camera: Camera2D = $ScreenCamera
var stun_camera_fade: float = 5
var stun_camera_shake: float = 5

func _ready() -> void:
	for enemy in enemy_container.get_children():
		enemy.EnemyStunned.connect(_on_enemy_stunned)
	
	

func _on_enemy_stunned(enemy: CharacterBody2D) -> void:
	screen_camera.activate_screen_shake(stun_camera_shake, stun_camera_fade)
