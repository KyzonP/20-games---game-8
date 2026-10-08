extends CanvasLayer

@onready var portraitSprite = find_child("Portrait")
@onready var dialogueText = find_child("DialogueText")
@onready var healthBar = find_child("HealthBar")
@onready var speedBar = find_child("SpeedBar")
@onready var volleySprite = find_child("VolleySize")
@onready var bombSprite = find_child("BombAmount")
@onready var scoreText = find_child("ScoreText")
@onready var endText = find_child("EndText")
@onready var deadText = find_child("DeadText")

@export var dialogueAppearTime : float = 2.0
@export var dialogueVanishTime : float = 1.0
var dialogueTween
var healthTween

var speed_node


func _ready():
	SaveLoad.load_data()
	
	EventBus.dialogue_trigger.connect(trigger_dialogue)
	EventBus.update_health.connect(update_health)
	EventBus.give_speed.connect(store_speed)
	EventBus.powerup_activated.connect(increase_volley)
	EventBus.bomb_activated.connect(decrease_bomb)
	EventBus.end_game.connect(end_text)
	EventBus.player_dead.connect(dead_text)
	
	dialogueText.visible_ratio = 0.0
	
func _physics_process(_delta):
	update_speed()
	
func store_speed(node):
	speed_node = node

func trigger_dialogue(character_name : String, dialogue : String):
	# Portrait
	if is_instance_valid(portraitSprite):
		portraitSprite.animation = character_name
		portraitSprite.visible = true
	
	# Dialogue
	if is_instance_valid(dialogueText):
		if dialogueTween:
			dialogueTween.kill()
			
		dialogueText.text = dialogue
		dialogueText.visible = true
			
		dialogueTween = create_tween()
		dialogueTween.tween_property(dialogueText, "visible_ratio", 1.0, dialogueAppearTime)
		
		dialogueTween.finished.connect(end_dialogue)
	
func end_dialogue():
	await get_tree().create_timer(dialogueVanishTime).timeout
	portraitSprite.visible = false
	
	dialogueText.visible = false
	dialogueText.visible_ratio = 0.0
	
func update_health(percentage):
	print(percentage)
	percentage = percentage * 100
	if is_instance_valid(healthBar):
		if healthTween:
			healthTween.kill()
		healthTween = create_tween()
		healthTween.tween_property(healthBar, "value", percentage, 0.2)
		
func update_speed():
	if is_instance_valid(speed_node):
		speedBar.value = speed_node.speed
		
func increase_volley():
	if is_instance_valid(volleySprite):
		volleySprite.position.x -= 16
		volleySprite.region_rect.size.x += 8
		
func decrease_bomb(_pos, _radius):
	if is_instance_valid(bombSprite):
		if bombSprite.region_rect.size.x > 0:
			bombSprite.region_rect.size.x -= 8
			
func dead_text():
	endText.visible = true
	deadText.visible = true
			
func end_text(score):
	if score > Global.highScore:
		scoreText.text = "[center]NEW HIGH SCORE: " + str(score)
		Global.highScore = score
	else:
		scoreText.text = "[center]SCORE: " + str(score)
	
	scoreText.visible = true
	endText.visible = true
	
	SaveLoad.save_game()
	
