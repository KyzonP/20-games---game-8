extends Area3D

@export var max_speed : float = 10.0
@export var acceleration : float = 10.0
@export var deceleration : float = 20.0
var x_speed : float = 0.0
var y_speed : float = 0.0
var speed
@export var x_margin : float = 13.0
@export var y_margin : float = 7.0

@onready var camera : Camera3D = get_parent()

func _physics_process(delta) -> void:
	# Get input direction
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if input_dir[0] < 0:
		x_speed = move_toward(x_speed, -max_speed, delta * acceleration)
	elif input_dir[0] > 0:
		x_speed = move_toward(x_speed, max_speed, delta * acceleration)
	else:
		x_speed = move_toward(x_speed, 0.0, delta * deceleration)
		
	if input_dir[1] < 0:
		y_speed = move_toward(y_speed, max_speed, delta * acceleration)
	elif input_dir[1] > 0:
		y_speed = move_toward(y_speed, -max_speed, delta * acceleration)
	else:
		y_speed = move_toward(y_speed, 0.0, delta * deceleration)
		
	position += Vector3(x_speed, y_speed, 0.0) * delta
	
	if camera:
		lock_to_camera()
		
func lock_to_camera() -> void:
	if position.x > x_margin:
		position.x = x_margin
	elif position.x < -x_margin:
		position.x = -x_margin
	
	if position.y > y_margin:
		position.y = y_margin
	elif position.y < -y_margin:
		position.y = -y_margin
