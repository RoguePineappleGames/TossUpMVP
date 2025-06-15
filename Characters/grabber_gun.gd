extends Area2D

#@onready var grab_particles: CPUParticles2D = $GrabParticles

var shoot_force_max: int = 3000
var shoot_force_min: int = 1000
var force_normalizing_factor: int = 50 


var has_enemy:
	set(new_value):
		has_enemy = new_value
		if !has_enemy:
			grabbed_enemy = null

	get:
		return has_enemy

#Player changes active gun based on orientation. On active gun change, the grabbed enemy value is updated for the new gun
#When we set new grabbed enemy, set the location of the new grabbed enemy to gun's location
#this is to ensure the grabbed enemy "rotates" with the player
var grabbed_enemy: 
	set(new_value):
		grabbed_enemy = new_value
		if grabbed_enemy:
			grabbed_enemy.reparent(self)
			grabbed_enemy.global_position = lerp(grabbed_enemy.global_position, global_position, 0.5)
	get:
		return grabbed_enemy


func scan_and_grab() -> CharacterBody2D:
	var enemies_in_vicinity = get_overlapping_bodies()
	if enemies_in_vicinity:
		#we want to grab first stunned enemy in vicinity
		for enemy in enemies_in_vicinity:
			if enemy.is_stunned:
				enemy.grab()
				has_enemy = true
				grabbed_enemy = enemy
				#if enemy.is_grabbed:
					#has_enemy = true
					#grabbed_enemy = enemy
				break
			else:
				continue
		if has_enemy:
			return grabbed_enemy
		else:
			return null
	
	else:
		print("No enemies detected")
		return null

func shoot(charge_time_left: float, total_charge_time: float):
	var aimed_direction = global_position.direction_to(get_global_mouse_position())
	
	#lerp expects normalized weight. So divide charge time left by total charge time to normalize
	#Do 1 - normalized ratio to get correct behavior of low force at high time left, high force at low time left
	var charge_progress = 1 - (charge_time_left/total_charge_time)
	#print("Charge progress: ", charge_progress)
	var adjusted_shoot_force = lerp(shoot_force_min, shoot_force_max, charge_progress)
	#print("Force: ", adjusted_shoot_force)
	
	#Apply throw damage and pass it to enemy throw function
	var throw_damage = calculate_throw_strength(adjusted_shoot_force)
	grabbed_enemy.throw(throw_damage)
	
	#Control velocity of enemy
	grabbed_enemy.velocity = aimed_direction * adjusted_shoot_force

	#let go of enemy from gun
	grabbed_enemy.reparent(get_tree().root)
	has_enemy = false
	grabbed_enemy = null


func calculate_throw_strength(force: float):
	var force_normalized = force / force_normalizing_factor
	return force_normalized
