class_name UpgradeCard
extends Node2D

signal UpgradeCardClicked(BaseUpgrade)

const HOVERED_DIM_VALUE: float = 0
const NOT_HOVERED_DIM_VALUE: float = 0.5

@export var card_stats: BaseUpgrade

@onready var upgrade_icon: Sprite2D = $PanelContainer/VBoxContainer/IconMarginContainer/UpgradeIcon
@onready var upgrade_name_label: RichTextLabel = $PanelContainer/VBoxContainer/NamePanel/UpgradeNameLabel
@onready var upgrade_description_label: RichTextLabel = $PanelContainer/VBoxContainer/DescriptionPanel/UpgradeDescriptionLabel
@onready var dimming_panel: Panel = $DimmingPanel


var card_name: String
var card_description: String
var card_icon: Texture2D
var card_rarity: String

var is_hovered: bool = false

func _ready() -> void:
	setup_card()
	#dimming_panel.visible = true

func setup_card() -> void:
	var bold_tag: String = "[b]"
	var italics_tag: String = "[i]"
	upgrade_name_label.text = bold_tag + card_stats.upgrade_name
	upgrade_description_label.text = italics_tag + card_stats.upgrade_description
	
	adjust_dimming(NOT_HOVERED_DIM_VALUE)

func spawn(spawn_coordinates: Vector2) -> void: 
	global_position = spawn_coordinates

func adjust_dimming(alpha_dimming_value) -> void:
	dimming_panel.self_modulate = Color(1, 1, 1, alpha_dimming_value)

func _on_area_2d_mouse_entered() -> void:
	is_hovered = true
	adjust_dimming(HOVERED_DIM_VALUE)
	#dimming_panel.visible = false
	

func _on_area_2d_mouse_exited() -> void:
	is_hovered = false
	adjust_dimming(NOT_HOVERED_DIM_VALUE)
	#dimming_panel.visible = true


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("Grab"):
		UpgradeCardClicked.emit(card_stats)
