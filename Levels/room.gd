extends Node2D

class_name Room

signal RoomDone(room_id: int)
signal RoomReset(room_id: int)
signal Room_PlayerDied(room_id: int)
signal Room_PlayerPaused(room_id: int)

@export var room_id: int = 0

@onready var screen_camera: Camera2D = $ScreenCamera
@onready var enemy_container: Node = $EnemyContainer
@onready var player: CharacterBody2D = $Player
@onready var player_spawn_position: Marker2D = $PlayerSpawnPosition



var stun_camera_fade: float = 5
var stun_camera_shake: float = 5
var player_hit_camera_fade: float = 10
var player_hit_camera_shake: float = 12
var enemy_dictionary: Dictionary = {}
var enemies_left: int = 0

func _ready() -> void:
	start_room()

func start_room() -> void:
	setup_player()
	setup_enemies()


func setup_player() -> void:
	#print(player)
	#print(player_spawn_position)
	player.global_position = player_spawn_position.global_position
	player.PlayerHit.connect(_on_player_hit)
	player.PlayerDied.connect(_on_player_death)
#	player.PlayerPaused.connect(_on_player_paused)

func setup_enemies() -> void:
	for enemy in enemy_container.get_children():
		enemy_dictionary[str(enemy)] = enemy.shape_type
		enemies_left += 1
		enemy.EnemyStunned.connect(_on_enemy_stunned)
		enemy.EnemyDied.connect(_on_enemy_died)
		if "player" in enemy:
			enemy.player = player


func restart_room() -> void:
	RoomReset.emit(room_id)
	get_tree().reload_current_scene()

func _on_player_hit() -> void:
	screen_camera.activate_screen_shake(player_hit_camera_fade, player_hit_camera_shake)

func _on_player_death() -> void:
	Room_PlayerDied.emit(room_id)

func _on_player_paused() -> void:
	Room_PlayerPaused.emit(room_id)

func _on_enemy_stunned(_enemy: CharacterBody2D) -> void:
	screen_camera.activate_screen_shake(stun_camera_shake, stun_camera_fade)

func _on_enemy_died(enemy: CharacterBody2D) -> void:
	enemy_dictionary.erase(str(enemy))
	enemies_left -= 1
	if enemies_left <= 0: 
		RoomDone.emit(room_id)
