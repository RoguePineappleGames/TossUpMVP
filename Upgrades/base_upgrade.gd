class_name BaseUpgrade
extends Resource

enum UPGRADE_CATEGORY {PLAYER, ENEMY}

enum UPGRADE_RARITY {COMMON, RARE, EPIC}

@export var upgrade_name: String
@export var upgrade_description: String
@export var upgrade_icon: Texture2D
@export var upgrade_category: UPGRADE_CATEGORY
@export var upgrade_rarity: UPGRADE_RARITY
@export var upgrade_modifier: float
