extends Area3D

@export var maxRotation : float = deg_to_rad(30.0)
@export var rotateAcceleration : float = 1.0
@export var max_speed : float = 10.0
@export var acceleration : float = 20.0
@export var deceleration : float = 10.0
var x_speed : float = 0.0
var y_speed : float = 0.0
var speed
@export var x_margin : float = 13.0
@export var y_margin : float = 7.0

@onready var camera : Camera3D = get_parent()

# Bullets
var bulletObject = load("res://scenes/bullet.tscn")

func _ready():
	area_entered.connect(collide)
	pass

func _input(_event):
	if Input.is_action_just_pressed("fire"):
		fireBullet()

func _physics_process(delta) -> void:
	move(delta)
	
	if camera:
		lock_to_camera()
		
func move(delta) -> void:
	# Get input direction
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if input_dir[0] < 0:
		x_speed = move_toward(x_speed, -max_speed, delta * acceleration)
		rotation.y = move_toward(rotation.y, maxRotation, delta * rotateAcceleration)
	elif input_dir[0] > 0:
		x_speed = move_toward(x_speed, max_speed, delta * acceleration)
		rotation.y = move_toward(rotation.y, -maxRotation, delta * rotateAcceleration)
	else:
		x_speed = move_toward(x_speed, 0.0, delta * deceleration)
		rotation.y = move_toward(rotation.y, 0, delta * rotateAcceleration)
		
	if input_dir[1] < 0:
		y_speed = move_toward(y_speed, max_speed, delta * acceleration)
		rotation.x = move_toward(rotation.x, maxRotation, delta * rotateAcceleration)
	elif input_dir[1] > 0:
		y_speed = move_toward(y_speed, -max_speed, delta * acceleration)
		rotation.x = move_toward(rotation.x, -maxRotation, delta * rotateAcceleration)
	else:
		y_speed = move_toward(y_speed, 0.0, delta * deceleration)
		rotation.x = move_toward(rotation.x, 0, delta * rotateAcceleration)
		
	position += Vector3(x_speed, y_speed, 0.0) * delta
		
func lock_to_camera() -> void:
	if position.x > x_margin:
		position.x = x_margin
	elif position.x < -x_margin:
		position.x = -x_margin
	
	if position.y > y_margin:
		position.y = y_margin
	elif position.y < -y_margin:
		position.y = -y_margin
		
func fireBullet() -> void:
	var bullet = bulletObject.instantiate()
	get_tree().root.get_child(0).add_child(bullet)
	bullet.global_position = $FirePoint.global_position
	bullet.rotation = global_rotation
	bullet.playerBullet()
	
func collide(_area) -> void:
	print("wow")
