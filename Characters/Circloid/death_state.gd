extends State

class_name DeathState

@onready var death_sfx: AudioStreamPlayer2D = $DeathSFX

func on_enter():
	death_sfx.playing = true
	await death_sfx.finished
	character.queue_free()
