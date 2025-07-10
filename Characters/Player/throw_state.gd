extends State

@export var move_state: State


var shoot_force_max: int = 3000
var shoot_force_min: int = 2000
var force_normalizing_factor: int = 50 

func on_enter() -> void:
	character.grabbed_enemy.throw()
	shoot(character.grabbed_enemy)
	character.grabbed_enemy = null
	Transitioned.emit(self, move_state)


func shoot(enemy: Enemy) -> void:
	var aimed_direction: Vector2 = character.global_position.direction_to(character.get_global_mouse_position())
	enemy.reparent(character.get_parent().get_node("EnemyContainer"))
	enemy.velocity = aimed_direction * shoot_force_min
	
	##lerp expects normalized weight. So divide charge time left by total charge time to normalize
	##Do 1 - normalized ratio to get correct behavior of low force at high time left, high force at low time left
	#var charge_progress = 1 - (charge_time_left/total_charge_time)
	#var adjusted_shoot_force = lerp(shoot_force_min, shoot_force_max, charge_progress)
	##Apply throw damage and pass it to enemy throw function
	#var throw_damage = calculate_throw_strength(adjusted_shoot_force)
	#grabbed_enemy.throw(throw_damage)
	#

#func calculate_throw_strength(force: float):
	#var force_normalized = force / force_normalizing_factor
	#return force_normalized
