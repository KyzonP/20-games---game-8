extends Node3D

@onready var player = find_child("Player").get_node("TargetPoint")

var score : int = 0
var life : int = 10
var lifeMax : int = 10

@onready var scoreText = find_child("ScoreText")
@onready var healthText = find_child("HealthText")

func _ready():
	EventBus.request_player.connect(_give_player)
	EventBus.player_hurt.connect(_adjustHealth)
	EventBus.score_increased.connect(_adjustScore)
	EventBus.boss_defeated.connect(_queue_end_dialogue)
	
	_adjustScore(0)
	_adjustHealth(0)
	
func _give_player():
	EventBus.emit_signal("give_player", player)

func _adjustScore(amount):
	score = score + amount
	scoreText.text = "Score : " + str(score)
	
func _adjustHealth(amount):
	life = life - amount
	EventBus.update_health.emit(float(life)/float(lifeMax))
	
	if life <= 0:
		EventBus.player_dead.emit()
	
func _queue_end_dialogue():
	EventBus.emit_signal("dialogue_trigger", "Guardian", "His forces are starting to retreat.")
	
	await get_tree().create_timer(4.0).timeout
	
	EventBus.emit_signal("dialogue_trigger", "Groknack", "HOPEFULLY THAT'S THE LAST WE SEE OF HIM!")
	
	await get_tree().create_timer(4.0).timeout
	
	EventBus.emit_signal("dialogue_trigger", "Bunny", "I'd call that a successful test flight!")
	
	await get_tree().create_timer(4.5).timeout
	
	EventBus.end_game.emit(score)
