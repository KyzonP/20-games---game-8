extends Area3D

# Movement
## Maximum the player ship can rotate during a move
@export var maxRotation : float = deg_to_rad(30.0)
## Acceleration of rotation
@export var rotateAcceleration : float = 1.0
## Maximum speed of player movement
@export var max_speed : float = 10.0
## Player acceleration
@export var acceleration : float = 20.0
## Player deceleration
@export var deceleration : float = 10.0
var x_speed : float = 0.0
var y_speed : float = 0.0
var speed
## Maximum x-axis movement
@export var x_margin : float = 13.0
## Maximum y-axis movement
@export var y_margin : float = 7.0

# Hurt buffer
## Time between injuries
@export var hurtBufferMax : float = 1.0
var hurtBufferTimer : float = 0.0

# Rolling
var rollTweenMove
var rollTweenRotate
var rolling : bool = false
## Distance covered by a barrel roll
@export var rollDistance : float = 10.0
## Duration of a barrel roll
@export var rollTime : float = 1.0

# Other nodes
@onready var camera : Camera3D = get_parent()
@onready var collider = find_child("Collider")

# Bullets
## Number of bullets fired in a volley
@export var bulletVolleyMax : int = 3
var bulletVolley : int = 0
## Max time between vollies
@export var bulletTimerMax : float = 0.75
var bulletTimer : float = 0.0
var bulletObject = load("res://scenes/bullet.tscn")

# bomb
## Maximum number of bombs carried by player
@export var bomb_max : int = 3
## Distance for enemy to be affected by the bomb
@export var bomb_radius : float = 300.0
@onready var bomb_current : int = bomb_max

func _ready():
	area_entered.connect(_collide)
	EventBus.powerup_activated.connect(_increase_volley_size)

func _input(_event):
	if not rolling:
		if Input.is_action_just_pressed("roll_left"):
			_roll("Left")
			
		if Input.is_action_just_pressed("roll_right"):
			_roll("Right")
			
	if Input.is_action_just_pressed("bomb"):
		_trigger_bomb()
		
func _trigger_bomb() -> void:
	if bomb_current > 0:
		bomb_current -= 1
		EventBus.bomb_activated.emit(global_position, bomb_radius)

func _physics_process(delta) -> void:
	move(delta)
	
	# damage cooldown
	if hurtBufferTimer <= hurtBufferMax:
		hurtBufferTimer += delta
		
	# bullet cooldown
	if not rolling:
		if Input.is_action_pressed("fire"):
			fireBullet()
	
	if bulletVolley >= bulletVolleyMax:
		bulletTimer += delta
		if bulletTimer >= bulletTimerMax:
			bulletVolley = 0
			bulletTimer = 0
	
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
	if bulletVolley < bulletVolleyMax:
		bulletVolley += 1
		var bullet = bulletObject.instantiate()
		get_tree().root.get_child(0).add_child(bullet)
		bullet.global_position = $FirePoint.global_position
		bullet.rotation = global_rotation
		bullet.playerBullet()
	
func _roll(direction : String) -> void:
	# disable shooting/rolling and collider
	rolling = true
	collider.disabled = true
	
	var targetX : float = 0.0
	var targetRotation = TAU
	# calculate destinations
	# moving x on pos, z on rotate (z increase as x decreases for left)
	if direction == "Left":
		targetX = position.x - rollDistance
		if targetX < -x_margin:
			targetX = -x_margin
	elif direction == "Right":
		targetX = position.x + rollDistance
		if targetX > x_margin:
			targetX = x_margin
		targetRotation *= -1
	
	if rollTweenMove:
		rollTweenMove.kill()
	rollTweenMove = create_tween()
	rollTweenMove.tween_property(self, "position", Vector3(targetX, position.y, position.z), rollTime)
	
	if rollTweenRotate:
		rollTweenRotate.kill()
	rollTweenRotate = create_tween()
	rollTweenRotate.tween_property(self, "rotation:z", targetRotation, rollTime).as_relative()
	
	rollTweenRotate.finished.connect(_end_roll)
		
func _end_roll() -> void:
	rolling = false
	collider.disabled = false
	
func _collide(area) -> void:
	if area.is_in_group("Bullet"):
		hurt(area.damage)

	###CODE FOR DETECTING TERRAIN
	if area.get_collision_layer_value(5):
		hurt(1)

func hurt(damage):
	if hurtBufferTimer >= hurtBufferMax:
		hurtBufferTimer = 0.0
		EventBus.player_hurt.emit(damage)
	
func _increase_volley_size() -> void:
	bulletVolleyMax += 1
