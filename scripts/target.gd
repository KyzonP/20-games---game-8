extends Node3D

@export var hp : float = 1.0
@export var points_value : int = 1

signal defeated(enemy_node)

# Bullets
var bulletObject = load("res://scenes/bullet.tscn")

func _ready():
	find_child("TargetTrigger").area_entered.connect(collide)
	
func destroy():
	defeated.emit(self)
	EventBus.score_increased.emit(points_value)
	find_child("TargetTrigger").get_parent().queue_free()

func collide(_area):
	destroy()
