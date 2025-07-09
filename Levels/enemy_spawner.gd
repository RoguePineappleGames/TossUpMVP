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
@export var total_number_of_enemies: int = 0
@export var max_concurrent_enemies: int = 0
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
	unspawned_enemies_left = total_number_of_enemies
	timer.wait_time = time_between_waves


func _on_timer_timeout() -> void:
	if circloid_allowed:
		spawn_enemy(CIRCLOID_SCENE)
		#spawn_enemy(CIRCLOID_SCENE)
	if triangoloid_allowed:
		spawn_enemy(TRIANGOLOID_SCENE)
	if blockoid_allowed:
		spawn_enemy(BLOCKOID_SCENE)

func spawn_enemy(enemy_scene: PackedScene) -> void:
	if enemies_currently_alive < max_concurrent_enemies:
		var enemy = enemy_scene.instantiate()
		enemy.EnemyStunned.connect(_on_enemy_stunned)
		enemy.EnemyDied.connect(_on_enemy_died)
		if "player" in enemy:
			enemy.player = player
		enemy_container.add_child(enemy)
		enemy.global_position = enemy1_marker.global_position
		unspawned_enemies_left -= 1
		enemies_currently_alive += 1
	else:
		print("Too many enemies alive")
	
func _on_enemy_stunned(enemy: Enemy) -> void:
	EnemySpawner_EnemyStunned.emit(enemy)


func _on_enemy_died(enemy: Enemy, score: int, enemy_position: Vector2) -> void:
	EnemySpawner_EnemyDied.emit(enemy, score)
	enemies_currently_alive -= 1
	var high_score_text_color: Color = Color.BROWN
	var low_score_text_color: Color = Color.YELLOW
	var text_color: Color
	if score >= 100:
		text_color = high_score_text_color
	else:
		text_color = low_score_text_color
	display_death_text(str(score), enemy_position, text_color)

func display_death_text(text_to_display: String, location_to_display_text: Vector2, text_color: Color) -> void:
	var label_size: Vector2 = Vector2(60, 60)
	var text_size: int = 25
	
	var tween_position_destination = location_to_display_text + Vector2(0, -50)
	var tween_duration: float = 0.5
	
	var new_text_label = Label.new()
	get_tree().root.add_child(new_text_label)
	
	new_text_label.size = label_size
	new_text_label.global_position = location_to_display_text
	new_text_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	new_text_label.set("theme_override_colors/font_color", text_color)
	new_text_label.set("theme_override_font_sizes/font_size", text_size )
	new_text_label.text = text_to_display
	
	var tween = create_tween()
	tween.tween_property(new_text_label, "position", tween_position_destination, tween_duration).set_trans(Tween.TRANS_SINE)
	
	await tween.finished
	new_text_label.queue_free()
	
	
