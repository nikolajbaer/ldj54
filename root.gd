extends Node3D

@onready var camera_pivot = $CameraPivot
@onready var truk = $Truk


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta):
	camera_pivot.global_position = truk.global_position
	if Input.is_action_just_pressed("escape"):
		# TODO escape to menu
		get_tree().quit()
	elif Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
