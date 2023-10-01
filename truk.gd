extends VehicleBody3D

signal collected(position)

@onready var fleft = $FrontLeft
@onready var fright = $FrontRight
@onready var rleft = $RearLeft
@onready var rright = $RearRight
@onready var anim = $Gripper/AnimationPlayer

var MAX_RPM = 500
var MAX_TORQUE = 200
var MAX_BRAKE = 10
var MAX_STEER = 30

var grabbing = 0

func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	steering = lerp(steering,Input.get_axis("right","left") * 0.4, 5*delta)

	if not Input.is_action_pressed("forward") and not Input.is_action_pressed("back"):
		rleft.engine_force = 0
		rright.engine_force = 0
		rleft.brake = MAX_BRAKE
		rright.brake = MAX_BRAKE
	else:
		var rpm = rleft.get_rpm()
		var acceleration = Input.get_axis("back","forward")
		rleft.engine_force = acceleration * MAX_TORQUE * (1-rpm / MAX_RPM)
		rpm = rright.get_rpm()
		rright.engine_force = acceleration * MAX_TORQUE * (1-rpm/MAX_RPM)
		rleft.brake = 0
		rright.brake = 0

	if Input.is_action_pressed("grab"):
		if grabbing == 0:
			anim.play("extend")
			grabbing = 1
	elif grabbing == 2:
		#print("retracting")
		anim.play("retract")
		grabbing = 3

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "extend":
		#print("grab finished")
		grabbing = 2
	elif anim_name == "retract":
		#print("done retracting")
		grabbing = 0

func _on_drop_zone_body_entered(body):
	if body.is_in_group("trashcan"):
		body.get_parent().add_to_group("collected")
		if body.global_transform.basis.y.dot(global_transform.basis.x) > 0:
			collected.emit(body.global_position)
		else:
			pass
			#print("woops!")
