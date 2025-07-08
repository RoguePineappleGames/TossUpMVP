extends Control

@onready var score: RichTextLabel = $HBoxContainer/LeftColumn/VBoxContainer/Score
@onready var kill_counter: RichTextLabel = $HBoxContainer/LeftColumn/VBoxContainer/KillCounter
@onready var health_bar: TextureProgressBar = $HBoxContainer/LeftColumn/VBoxContainer/HealthBar
@onready var level_timer: RichTextLabel = $HBoxContainer/RightColumn/VBoxContainer/LevelTimer
@onready var dash_cooldown: TextureProgressBar = $HBoxContainer/RightColumn/VBoxContainer/DashCooldown
