extends Node3D

@onready var highScoreText = find_child("HighScoreText")
@onready var startButton = find_child("StartButton")

func _ready():
	SaveLoad.load_data()
	
	highScoreText.text = "[center]HIGH SCORE : " + str(Global.highScore)
	
	if is_instance_valid(startButton):
		startButton.pressed.connect(_start)

func _start():
	get_tree().change_scene_to_file("res://levels/level 1/level_1.tscn")
