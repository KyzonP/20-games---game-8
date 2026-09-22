extends Area3D

@export var damageMultiplier : float = 1.0

signal hurt(damage, damageMultiplier)

func _ready():
	area_entered.connect(_collide)
	
func _collide(_area):
	hurt.emit(_area.damage, damageMultiplier)
