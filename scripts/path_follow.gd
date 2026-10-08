extends PathFollow3D

@export var maxSpeed : float = 30.0
@export var baseSpeed : float = 20.0
@export var minSpeed : float = 10.0

@export var acceleration : float = 10.0
@export var deceleration : float = 10.0

var speed : float = 10.0

var stopped : bool = false

func _ready():
	EventBus.give_speed.emit(self)
	EventBus.player_dead.connect(_stop)

func _physics_process(delta):
	if not stopped:
		if Input.is_action_pressed("boost"):
			speed = move_toward(speed, maxSpeed, delta * acceleration)
		elif Input.is_action_pressed("brake"):
			speed = move_toward(speed, minSpeed, delta * deceleration)
		else:
			speed = move_toward(speed, baseSpeed, delta * deceleration)

		progress += delta * speed
		
		if Input.is_action_just_pressed("test_speed_up"):
			progress += 500
	else:
		speed = move_toward(speed, 0, delta * deceleration)
		
func _stop():
	stopped = true
