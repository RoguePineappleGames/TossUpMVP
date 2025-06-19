extends Node

enum ShapeType {CIRCLOID, TRIANGOLOID, BLOCKOID, RHOMBOID, STAROID}

const SHAPE_WEAKNESS_DICTIONARY: Dictionary = {
	ShapeType.CIRCLOID: ShapeType.CIRCLOID,
	ShapeType.TRIANGOLOID: ShapeType.BLOCKOID,
	ShapeType.BLOCKOID: ShapeType.RHOMBOID,
	ShapeType.RHOMBOID: ShapeType.STAROID,
	ShapeType.STAROID: ShapeType.CIRCLOID
}


func does_shape_beat_shape(attacker: ShapeType, defender: ShapeType) -> bool:
	if SHAPE_WEAKNESS_DICTIONARY.get(attacker) == defender:
		return true
	else:
		return false
