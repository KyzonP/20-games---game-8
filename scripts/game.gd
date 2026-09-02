extends Node3D

@export var player : Area3D

func _ready():
	EventBus.emit_signal("give_player", player)
