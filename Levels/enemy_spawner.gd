extends Node2D

@export var player: CharacterBody2D

var toaster_scene = preload("res://Characters/toaster_bot.tscn")
var shielder_scene = preload("res://Characters/shielder.tscn")
var relentless_scene = preload("res://Characters/relentless_bot.tscn")

var enemies_left: int = 100
var rng = RandomNumberGenerator.new()


func _on_timer_timeout() -> void:
	spawn_enemy()

func spawn_enemy() -> void: 
	if enemies_left > 0:
		var random_number = rng.randi_range(1, 2)
		if random_number == 1:
			instantiate_enemy(toaster_scene)
		elif random_number == 2:
			instantiate_enemy(shielder_scene)
		elif random_number == 3:
			var enemy = instantiate_enemy(relentless_scene)
			enemy.player = player
			

func instantiate_enemy(enemy_scene):
	var enemy = enemy_scene.instantiate()
	get_tree().root.add_child(enemy)
	enemy.global_position = global_position
	return enemy
