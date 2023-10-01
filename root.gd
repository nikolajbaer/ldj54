extends Node3D


@onready var points = preload("res://points.tscn")

@onready var camera_pivot = $CameraPivot
@onready var truk = $Truk
@onready var startZone = $StartZone
@onready var elapsedLabel = $HUD/Elapsed
@onready var scoreLabel = $HUD/Score

var elapsed = null
var score = 0
var trashcans
var show_start_text = true
	
func _ready():
	$HUD/StartText.visible = true
	$HUD/ScorePanel.visible = false
	$CameraPivot.set_truk(truk)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elapsed = null
	score = 0
	#TODO listen to all trees and cars for negative scores
	var penalties = get_tree().get_nodes_in_group("penalty")
	for body in penalties:
		body.body_entered.connect(_on_penalty.bind(body))
	trashcans = get_tree().get_nodes_in_group("trashcan")
	for trashcan in trashcans:
		trashcan.knocked_over.connect(_on_knocked_over)
	
func _physics_process(delta):
	if elapsed != null:
		elapsed += delta
	if Input.is_action_just_pressed("escape"):
		# TODO escape to menu
		get_tree().change_scene_to_file('res://intro.tscn')
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
		$CameraPivot.set_started()

func _on_start_zone_body_entered(body):
	if body == truk and elapsed != null and elapsed > 5:
		print("Game Over!")
		# Add Time bonus
		
		var cans = len(get_tree().get_nodes_in_group("trashcan"))
		var collected = len(get_tree().get_nodes_in_group("collected"))
		var collect_bonus = 0
		if collected == cans:
			collect_bonus = 50
			
		var time_bonus = 160 - elapsed
		if collected < cans*0.8: time_bonus = 0
		if time_bonus < 0: time_bonus = 0
		
		score += time_bonus
		score += collect_bonus
					
		$HUD/ScorePanel/CanScore.text = "%02d" % collect_bonus
		$HUD/ScorePanel/TimeScore.text = "%02d" % time_bonus
		$HUD/ScorePanel/Score.text = "%d" % score
		$HUD/ScorePanel.visible = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		truk.active = false
		elapsed = null

func _on_truk_collected(position):
	showScoreChange(30,position)

func _on_penalty(body,penalty):
	if body.is_in_group("truk") and not penalty.is_in_group("penalty_hit"):
		penalty.add_to_group("penalty_hit")
		showScoreChange(-30,penalty.global_position)

func _on_knocked_over(position):
	showScoreChange(-10,position)

func _on_animation_player_animation_finished(anim_name):
	$HUD/StartText.visible = false

func _input(event):
	if show_start_text:
		$HUD/AnimationPlayer.play("start_game")
		show_start_text = false

func _on_button_pressed():
	get_tree().reload_current_scene()

func _on_button_2_pressed():
	get_tree().change_scene_to_file('res://intro.tscn')
