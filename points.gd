extends Node2D

func _ready():
	$AnimationPlayer.play("points")

func set_init(text,x,y,color):
	$Node2D/Label.text = text
	$Node2D/Label.modulate = color
	position.x = x
	position.y = y

func _on_animation_player_animation_finished(anim_name):
	queue_free()
