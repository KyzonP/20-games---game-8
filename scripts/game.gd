extends Node3D

@onready var player = find_child("Player")

var score : int = 0
var life : int = 10

@onready var scoreText = find_child("ScoreText")
@onready var healthText = find_child("HealthText")

func _ready():
	EventBus.request_player.connect(_give_player)
	EventBus.player_hurt.connect(_adjustHealth)
	EventBus.score_increased.connect(_adjustScore)
	
	_adjustScore(0)
	_adjustHealth(0)
	
func _give_player():
	EventBus.emit_signal("give_player", player)

func _adjustScore(amount):
	score = score + amount
	scoreText.text = "Score : " + str(score)
	
func _adjustHealth(amount):
	life = life - amount
	healthText.text = "Health: " + str(life)
