extends Sprite2D

func _ready():
	ghosting()
	
	
func set_property(ghost_position: Vector2, ghost_scale: Vector2, ghost_flip_h):
	position = ghost_position
	scale = ghost_scale
	flip_h = ghost_flip_h
	
func ghosting():
	var tween_fade = get_tree().create_tween()
	
	tween_fade.tween_property(self, "modulate", Color(0, 0, 1, 0), 0.75)
	await tween_fade.finished
	
	queue_free()
