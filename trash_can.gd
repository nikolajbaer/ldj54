extends Node3D

signal knocked_over(position)
@onready var base = $Base

var knocked_over_recorded = false

func _physics_process(delta):
	if not base.sleeping and not knocked_over_recorded:
		if base.global_position.y < 0.5 and base.global_transform.basis.y.dot(Vector3.UP) < 0.8:
			print(base.global_transform.basis.y)
			knocked_over_recorded = true
			knocked_over.emit(global_position)
