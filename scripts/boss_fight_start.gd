extends Area3D

var triggered : bool = false

signal start_fight

func _ready():
	area_entered.connect(_collide)
	
func _collide(_area):
	if not triggered:
		print("entered")
		triggered = true
		start_fight.emit()
