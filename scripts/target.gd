extends Area3D

@export var hp : float = 1.0
@export var points_value : int = 1

signal defeated(enemy_node)

# Bullets
var bulletObject = load("res://scenes/bullet.tscn")

func _ready():
	area_entered.connect(collide)
	
func destroy():
	defeated.emit(self)
	EventBus.score_increased.emit(points_value)
	$VehicleShape.queue_free()
	$CollisionShape3D.disabled = true

func collide(_area):
	destroy()
