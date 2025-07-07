extends Node2D

signal EnemySpawner_EnemyDied(enemy: Enemy, score: int)
signal EnemySpawner_EnemyStunned(enemy: Enemy)

const CIRCLOID_SCENE = preload("res://Characters/Circloid/circloid.tscn")
const TRIANGOLOID_SCENE = preload("res://Characters/Triangoloid/triangoloid.tscn")
const BLOCKOID_SCENE = preload("res://Characters/Blockoid/blockoid.tscn")

@export var player: CharacterBody2D
@export var enemy_container: Node2D

@export_category("Enemies")
@export var circloid_allowed: bool = false
@export var triangoloid_allowed: bool = false
@export var blockoid_allowed: bool = false
@export var rhomboid_allowed: bool = false
@export var staroid_allowed: bool = false
@export var max_number_of_enemies: int = 0
@export var time_between_waves: float = 1

@export_category("Enemy Locations")
@export var enemy1_marker: Marker2D
@export var enemy2_marker: Marker2D
@export var enemy3_marker: Marker2D
@export var enemy4_marker: Marker2D

@onready var timer: Timer = $Timer



var unspawned_enemies_left: int = 0
var enemies_currently_alive: int = 0

func _ready() -> void:
	unspawned_enemies_left = max_number_of_enemies
	timer.wait_time = time_between_waves


func _on_timer_timeout() -> void:
	if circloid_allowed:
		spawn_enemy(CIRCLOID_SCENE)
		spawn_enemy(CIRCLOID_SCENE)


func spawn_enemy(enemy_scene: PackedScene) -> void:
	var enemy = enemy_scene.instantiate()
	enemy.EnemyStunned.connect(_on_enemy_stunned)
	enemy.EnemyDied.connect(_on_enemy_died)
	if "player" in enemy:
		enemy.player = player
	enemy_container.add_child(enemy)
	enemy.global_position = enemy1_marker.global_position
	unspawned_enemies_left -= 1
	enemies_currently_alive += 1
	
	
func _on_enemy_stunned(enemy: Enemy) -> void:
	EnemySpawner_EnemyStunned.emit(enemy)


func _on_enemy_died(enemy: Enemy, score: int) -> void:
	EnemySpawner_EnemyDied.emit(enemy, score)
	enemies_currently_alive -= 1


#func setup_enemies() -> void:
	#for enemy in enemy_container.get_children():
		#enemy_dictionary[str(enemy)] = enemy.shape_type
		#enemies_left += 1
		#enemy.EnemyStunned.connect(_on_enemy_stunned)
		#enemy.EnemyDied.connect(_on_enemy_died)
		#if "player" in enemy:
			#enemy.player = player
