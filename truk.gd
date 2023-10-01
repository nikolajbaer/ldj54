extends VehicleBody3D

signal collected(position)

@export var active = true
@onready var fleft = $FrontLeft
@onready var fright = $FrontRight
@onready var rleft = $RearLeft
@onready var rright = $RearRight
@onready var anim = $Gripper/AnimationPlayer
@onready var engineAudio = $AudioStreamPlayer
@onready var brakeAudio = $BrakesAudioStreamPlayer2
@onready var idleAudio = $IdleAudioStreamPlayer2
var MAX_RPM = 500
var MAX_TORQUE = 200
var MAX_BRAKE = 10
var MAX_STEER = 30

var grabbing = 0
var stopped = true

func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	steering = lerp(steering,Input.get_axis("right","left") * 0.4, 5*delta)

	if not active or (not Input.is_action_pressed("forward") and not Input.is_action_pressed("back")):
		if not idleAudio.playing: idleAudio.play()
		if not stopped:
			brakeAudio.play()
		if linear_velocity.length_squared() < 0.1:
			brakeAudio.stop()
		stopped = true
		engineAudio.stop()
		rleft.engine_force = 0
		rright.engine_force = 0
		rleft.brake = MAX_BRAKE
		rright.brake = MAX_BRAKE
	else:
		var rpm = rleft.get_rpm()
		var acceleration = Input.get_axis("back","forward")
		if stopped:
			idleAudio.stop()
			engineAudio.play()
			brakeAudio.stop()
			stopped = false
		rleft.engine_force = acceleration * MAX_TORQUE * (1-rpm / MAX_RPM)
		rpm = rright.get_rpm()
		rright.engine_force = acceleration * MAX_TORQUE * (1-rpm/MAX_RPM)
		rleft.brake = 0
		rright.brake = 0

	if Input.is_action_pressed("grab"):
		if grabbing == 0:
			$CollectStartAudioStreamPlayer2.play()
			anim.play("extend")
			grabbing = 1
	elif grabbing == 2:
		#print("retracting")
		$RetractAudioStreamPlayer2.play()
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
	var parent = body.get_parent()
	if parent.is_in_group("trashcan") and not parent.is_in_group("collected"):
		parent.add_to_group("collected")
		if body.global_transform.basis.y.dot(global_transform.basis.x) > 0:
			collected.emit(body.global_position)
			$CollectAudioStreamPlayer.play()
		else:
			pass
			#print("woops!")


func _on_audio_stream_player_finished():
	engineAudio.play(3)
