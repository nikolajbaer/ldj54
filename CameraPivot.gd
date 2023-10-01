extends Node3D

var direction = Vector3.FORWARD
@export var smooth_speed = 2.5
@export var mouse_sensitivity = 0.002
@export var auto_camera = true
@onready var timer = $Timer
@onready var timer2 = $Timer2

var side_look = false
var truk = null
var started = false

func _ready():
	side_look = false

func set_truk(body):
	truk = body

func set_started():
	started = true

func _physics_process(delta):
	if truk != null: global_position = truk.global_position
	if auto_camera and truk:
		var current_velocity = truk.get_linear_velocity()
		current_velocity.y = 0
		if current_velocity.length_squared() > 3:
			timer.stop()
			side_look = false
			direction = lerp(direction,-current_velocity.normalized(),smooth_speed*delta)
		elif side_look:
			var side_dir = (truk.global_transform.basis.z).cross(Vector3.UP)
			direction = lerp(direction,side_dir.normalized(),smooth_speed*delta)
		else:
			if timer.is_stopped():
				timer.start()
		global_transform.basis = get_rotation_from_direction(direction)

func get_rotation_from_direction(look_direction:Vector3) -> Basis:
	look_direction = look_direction.normalized()
	var x_axis = look_direction.cross(Vector3.UP)
	return Basis(x_axis,Vector3.UP,-look_direction)	

func _unhandled_input(event):
	if event is InputEventMouseMotion and not auto_camera:
		rotate_y(-event.relative.x * mouse_sensitivity)

func _on_timer_timeout():
	if started:
		side_look = true
