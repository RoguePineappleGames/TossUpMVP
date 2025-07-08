class_name Level
extends Node2D

@export var level_max_time: int = 100

@onready var player: CharacterBody2D = $Player
@onready var player_spawn_position: Marker2D = $PlayerSpawnPosition

@onready var enemy_spawner: Node2D = $EnemySpawner
@onready var enemy_container: Node = $EnemySpawner/EnemyContainer

@onready var screen_camera: Camera2D = $ScreenCamera

@onready var pause_menu: Control = $PauseMenu
@onready var hud: Control = $HUD
@onready var level_timer: Timer = $LevelTimer



var stun_camera_fade: float = 5
var stun_camera_shake: float = 5
var player_hit_camera_fade: float = 10
var player_hit_camera_shake: float = 20

var player_current_health: float = 0
var player_score: int = 0
var total_enemies_killed: int = 0


func _ready() -> void:
	toggle_pause_menu(false)
	setup_enemy_handler()
	setup_player()
	setup_level_timer()


func _physics_process(delta: float) -> void:
	update_hud()


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

func setup_level_timer() -> void:
	level_timer.wait_time = level_max_time
	level_timer.start()
	level_timer.one_shot = true

func update_hud() -> void:
	hud.score.text = str(player_score)
	hud.kill_counter.text = str(total_enemies_killed)
	hud.level_timer.text = str(int(level_timer.time_left))
	if player:
		hud.health_bar.value = player.current_health
		hud.health_bar.max_value = player.max_health
		hud.dash_cooldown.value = return_converted_dash_cooldown_left()
		
func return_converted_dash_cooldown_left():
	if player:
		var dash_cooldown: float = player.dash_cooldown_timer.wait_time
		var time_left_on_dash: float = player.return_remaining_dash_cooldown()
		return remap(time_left_on_dash, dash_cooldown, 0, 0, 100)
	else:
		return 100

func toggle_pause_menu(toggle: bool) -> void:
	pause_menu.visible = toggle

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
