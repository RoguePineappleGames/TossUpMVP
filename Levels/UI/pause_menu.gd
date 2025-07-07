extends Control

#signal PlayButtonPressed
signal RetryButtonPressed
signal ExitButtonPressed
signal SettingsButtonPressed

@onready var play_button: TextureButton = $ButtonContainer/PlayButton
@onready var retry_button: TextureButton = $ButtonContainer/RetryButton
@onready var settings_button: TextureButton = $ButtonContainer/SettingsButton
@onready var exit_button: TextureButton = $ButtonContainer/ExitButton


func _ready() -> void:
	visible = true

func unpause() -> void:
	get_tree().paused = false
	visible = false

func _on_play_button_pressed() -> void:
	unpause()

func _on_retry_button_pressed() -> void:
	unpause()
	RetryButtonPressed.emit()


func _on_exit_button_pressed() -> void:
	unpause()
	ExitButtonPressed.emit()


func _on_settings_button_pressed() -> void:
	unpause()
	SettingsButtonPressed.emit()


func _on_play_button_mouse_entered() -> void:
	play_button.modulate = Color("9b9b9b")
	

func _on_play_button_mouse_exited() -> void:
	play_button.modulate = Color("ffffff")
	

func _on_retry_button_mouse_entered() -> void:
	retry_button.modulate = Color("9b9b9b")


func _on_retry_button_mouse_exited() -> void:
	retry_button.modulate = Color("ffffff")


func _on_settings_button_mouse_entered() -> void:
	settings_button.modulate = Color("9b9b9b")


func _on_settings_button_mouse_exited() -> void:
	settings_button.modulate = Color("ffffff")


func _on_exit_button_mouse_entered() -> void:
	exit_button.modulate = Color("9b9b9b")


func _on_exit_button_mouse_exited() -> void:
	exit_button.modulate = Color("ffffff")
