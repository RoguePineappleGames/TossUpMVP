extends Node2D

signal LevelDone

@export var level_id: int = 0

@onready var pause_menu: Control = $PauseMenu
@onready var portal: Area2D = $Portal
@onready var portal_spawn_position: Marker2D = $PortalSpawnPosition

@onready var room_container: Node = $RoomContainer
@onready var room0_1_scene: PackedScene = preload("res://Levels/Level0/room_0_1.tscn")
@onready var room0_2_scene: PackedScene = preload("res://Levels/Level0/room_0_2.tscn")
@onready var room0_3_scene: PackedScene = preload("res://Levels/Level0/room_0_3.tscn")
@onready var room0_4_scene: PackedScene
@onready var room0_5_scene: PackedScene
@onready var room0_6_scene: PackedScene
@onready var room0_7_scene: PackedScene
@onready var room0_8_scene: PackedScene
@onready var rooms_left_array: Array = [room0_1_scene, room0_2_scene, room0_3_scene, room0_4_scene, 
room0_5_scene, room0_6_scene, room0_7_scene, room0_8_scene]

var current_active_room: Node2D
var current_active_room_id: int = 0
var rooms_left: int = 0

func _ready() -> void:
	pause_menu.visible = false
	setup_portal(false)
	#print(rooms_left_array)
	setup_next_room()
	

func setup_next_room() -> void:
	
	setup_portal(false)
	rooms_left = rooms_left_array.size()
	
	if current_active_room:
		current_active_room.queue_free()
		
	if rooms_left > 0:
		var next_room_scene = rooms_left_array[0]
		var next_room_instance = next_room_scene.instantiate()
		#room_container.call_deferred("add_child", next_room_instance)
		room_container.add_child(next_room_instance)
		current_active_room = next_room_instance
		current_active_room_id = next_room_instance.room_id
		
		next_room_instance.RoomDone.connect(_on_room_done)
		next_room_instance.Room_PlayerDied.connect(_on_room_player_died)
		next_room_instance.Room_PlayerPaused.connect(_on_room_player_paused)
		
		##To avoid issues with calling this function before room is ready, call start_room in room's ready method. 
		#current_active_room.start_room()
		#current_active_room.call_deferred("start_room")
		
	else:
		LevelDone.emit()


func restart_current_room() -> void:
	current_active_room.restart_room()


func _on_room_done(room_id: int) -> void:
	rooms_left_array.pop_front()
	setup_portal(true)
	#setup_next_room()


func show_pause_menu() -> void:
	pause_menu.visible = true


func setup_portal(activate: bool) -> void:
	portal.visible = activate
	portal.monitoring = activate


func _on_room_player_died(room_id: int) -> void:
	print("in Room: ", str(room_id), ", the player has died")


func _on_room_player_paused(room_id: int) -> void:
	print("in Room: ", str(room_id), ", the player has paused")
	show_pause_menu()
	get_tree().paused = true


func _on_portal_body_entered(body: Node2D) -> void:
	##use call_deferred otherwise will cause bugs
	call_deferred("setup_next_room")

func _on_pause_menu_retry_button_pressed() -> void:
	restart_current_room()


func _on_pause_menu_exit_button_pressed() -> void:
	pass # Replace with function body.


func _on_pause_menu_settings_button_pressed() -> void:
	pass # Replace with function body.
