extends State

class_name DeathState

@onready var death_sfx: AudioStreamPlayer2D = $DeathSFX

func on_enter():
	character.EnemyDied.emit(character)
	death_sfx.playing = true
	await death_sfx.finished
	character.queue_free()
