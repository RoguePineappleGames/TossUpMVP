class_name Level
extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var player_spawn_position: Marker2D = $PlayerSpawnPosition


@onready var enemy_spawner: Node2D = $EnemySpawner
@onready var enemy_container: Node = $EnemySpawner/EnemyContainer

@onready var pause_menu: Control = $PauseMenu

@onready var screen_camera: Camera2D = $ScreenCamera

var stun_camera_fade: float = 5
var stun_camera_shake: float = 5
var player_hit_camera_fade: float = 5
var player_hit_camera_shake: float = 12
var player_score: int = 0

func _ready() -> void:
	toggle_pause_menu(false)
	setup_player()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Pause"):
		toggle_pause_menu(true)
		get_tree().paused = true

func setup_enemy_handler() -> void:
	enemy_spawner.EnemySpawner_EnemyStunned.connect(_on_enemy_spawner_enemy_stunned)
	enemy_spawner.EnemySpawner_EnemyDied.connect(_on_enemy_spawner_enemy_died)

func setup_player() -> void:
	player.global_position = player_spawn_position.global_position
	player.PlayerHit.connect(_on_player_hit)
	player.PlayerDied.connect(_on_player_death)


func toggle_pause_menu(show: bool) -> void:
	pause_menu.visible = show


func _on_player_hit() -> void:
	screen_camera.activate_screen_shake(player_hit_camera_fade, player_hit_camera_shake)

func _on_player_death() -> void:
	pass

func _on_enemy_spawner_enemy_stunned(_enemy: Enemy) -> void:
	screen_camera.activate_screen_shake(stun_camera_fade, stun_camera_shake)

func _on_enemy_spawner_enemy_died(_enemy: Enemy, score: int) -> void:
	player_score += score

func _on_pause_menu_retry_button_pressed() -> void:
	pass

func _on_pause_menu_exit_button_pressed() -> void:
	pass # Replace with function body.


func _on_pause_menu_settings_button_pressed() -> void:
	pass # Replace with function body.
