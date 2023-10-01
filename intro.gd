extends Node3D

@onready var TrashCan = preload("res://trash_can.tscn")
var trash_start_pos = null
@onready var trash_can = $TrashCan
@onready var timer = $Timer
var camera

func _ready():
	AudioServer.set_bus_mute(0,true)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	trash_start_pos = $TrashCan.global_position
	camera = get_viewport().get_camera_3d()

func _process(delta):
	$Control/Fwd.position = camera.unproject_position($Truk/Fwd/Marker3D.global_position)
	$Control/Back.position = camera.unproject_position($Truk/Back/Marker3D.global_position)
	$Control/Left.position = camera.unproject_position($Truk/Left/Marker3D.global_position)
	$Control/Right.position = camera.unproject_position($Truk/Right/Marker3D.global_position)
	$Control/Grab.position = camera.unproject_position(trash_can.global_position)

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			get_tree().quit()

func _on_button_pressed():
	get_tree().change_scene_to_file('res://root.tscn')

func _on_button_2_pressed():
	get_tree().quit()

func _on_truk_collected(position):
	timer.start()

func _on_timer_timeout():
	trash_can.queue_free()
	var new_trash_can = TrashCan.instantiate()
	new_trash_can.global_position = trash_start_pos
	trash_can = new_trash_can
	add_child(new_trash_can)

func _on_check_box_toggled(button_pressed):
	AudioServer.set_bus_mute(0,not button_pressed)


func _on_check_box_2_toggled(button_pressed):
	var player_vars = get_node("/root/PlayerVariables")
	player_vars.mouse_look = button_pressed
