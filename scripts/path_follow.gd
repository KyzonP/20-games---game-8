extends PathFollow3D

@export var speed : float = 10.0

func _physics_process(delta):
	progress += delta * speed
