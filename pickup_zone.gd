extends Area3D

signal penalty(amount,position)

func _on_body_exited(body):
	if body.is_in_group("collected"):
		print("out of landing zone")
		penalty.emit(-10,body.global_position)
