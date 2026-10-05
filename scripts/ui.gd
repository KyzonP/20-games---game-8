extends CanvasLayer

@onready var portraitSprite = find_child("Portrait")
@onready var dialogueText = find_child("DialogueText")

@export var dialogueAppearTime : float = 1.0
@export var dialogueVanishTime : float = 0.5
var dialogueTween


func _ready():
	EventBus.dialogue_trigger.connect(trigger_dialogue)

func trigger_dialogue(character_name : String, dialogue : String):
	# Portrait
	portraitSprite.animation = character_name
	portraitSprite.visible = true
	
	# Dialogue
	if dialogueTween:
		dialogueTween.kill()
		
	dialogueText.text = dialogue
	dialogueText.visible = true
		
	dialogueTween = create_tween()
	dialogueTween.tween_property(dialogueText, "visible_ratio", 1.0, dialogueAppearTime)
	
	dialogueTween.finished.connect(end_dialogue)
	
func end_dialogue():
	await get_tree().create_timer(0.5).timeout
	portraitSprite.visible = false
	
	dialogueText.visible = false
	dialogueText.visible_ratio = 0.0
