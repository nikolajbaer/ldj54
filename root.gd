extends Node3D

@onready var points = preload("res://points.tscn")

@onready var camera_pivot = $CameraPivot
@onready var truk = $Truk
@onready var startZone = $StartZone
@onready var elapsedLabel = $HUD/Elapsed
@onready var scoreLabel = $HUD/Score

var elapsed = null
var score = 0
	
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elapsed = null
	score = 0
	#TODO listen to all trees and cars for negative scores
	var penalties = get_tree().get_nodes_in_group("penalty")
	for body in penalties:
		body.body_entered.connect(_on_penalty.bind(body))
	var trashcans = get_tree().get_nodes_in_group("trashcanbase")
	
func _physics_process(delta):
	if elapsed != null:
		elapsed += delta
	camera_pivot.global_position = truk.global_position
	if Input.is_action_just_pressed("escape"):
		# TODO escape to menu
		get_tree().quit()
	elif Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()

func _process(delta):
	if elapsed != null:
		elapsedLabel.text = "%0.1f" % elapsed

func showScoreChange(amount,position):
	score += amount
	scoreLabel.text = "Score: %s" % score
	var p = points.instantiate()
	var txt = "%d"%amount
	if amount > 0: txt = "+%s" % txt
	var screenpos = get_viewport().get_camera_3d().unproject_position(position)
	var color = Color("00ff00")
	if amount < -10: color = Color("ff0000")
	elif amount < 0: color = Color("ffff00")
	p.set_init(txt,screenpos.x,screenpos.y,color)
	$HUD.add_child(p)

func _on_start_zone_body_exited(body):
	if body == truk and elapsed == null:
		print("Game Started")
		elapsed = 0

func _on_start_zone_body_entered(body):
	if body == truk and elapsed != null and elapsed > 5:
		print("Game Over!")
		elapsed = null

func _on_truk_collected(position):
	showScoreChange(30,position)

func _on_penalty(body,penalty):
	if body.is_in_group("truk") and not penalty.is_in_group("penalty_hit"):
		penalty.add_to_group("penalty_hit")
		showScoreChange(-30,penalty.global_position)

func _on_trashcan_sleep(body):
	if body.sleeping and body.get_parent().is_in_group("collected"):
		print("Sleeping collected trashcan")
	
