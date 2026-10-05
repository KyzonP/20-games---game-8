extends Area3D

@export_enum("Bunny", "Guardian", "Groknack") var character : String

@export var dialogue : String

func _ready():
	area_entered.connect(_trigger_dialogue)
	
func _trigger_dialogue(_area) -> void:
	EventBus.emit_signal("dialogue_trigger", character, dialogue)
	
	self.queue_free()
