extends State

class_name DeathState

@onready var death_sfx: AudioStreamPlayer2D = $DeathSFX

var skew_final_value: float = 90

func on_enter():
	#play_death_animation()
	character.EnemyDied.emit(character, character.death_score, character.global_position)
	death_sfx.playing = true
	await death_sfx.finished
	character.queue_free()

#func play_death_animation() -> void:
	#death_sfx.playing = true
	#await death_sfx.finished
	#var tween = create_tween()
	#tween.tween_property(character.animated_sprite_2d, "skew", skew_final_value, 1).set_trans(Tween.TRANS_BOUNCE)
	#await tween.finished
