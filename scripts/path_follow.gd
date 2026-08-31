extends PathFollow3D

@export var maxSpeed : float = 30.0
@export var baseSpeed : float = 20.0
@export var minSpeed : float = 10.0

@export var acceleration : float = 10.0
@export var deceleration : float = 10.0

var speed : float = 10.0

func _physics_process(delta):
	if Input.is_action_pressed("boost"):
		speed = move_toward(speed, maxSpeed, delta * acceleration)
	elif Input.is_action_pressed("brake"):
		speed = move_toward(speed, minSpeed, delta * deceleration)
	else:
		speed = move_toward(speed, baseSpeed, delta * deceleration)

	progress += delta * speed
	
