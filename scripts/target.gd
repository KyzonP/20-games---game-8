extends Area3D

@export var hp : float = 1.0

signal defeated(enemy_node)

# Bullets
var bulletObject = load("res://scenes/bullet.tscn")

func _ready():
	area_entered.connect(collide)
	
func destroy():
	defeated.emit(self)
	queue_free()

func collide(_area):
	destroy()
