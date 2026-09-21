extends Node3D

### Stats ###
@export var hp : float = 50.0
@export var speed : float = 15.0

@export var moveTime : float = 10.0

@export var floatPosArray : PackedVector3Array = [
	Vector3(1000,50,0),
	Vector3(1000,-50,0),
	Vector3(1000,0,50),
	Vector3(1000,0,-50)
]

@export var firePos : Vector3 = Vector3(980,0,0)
@export var fireRot : Vector3 = Vector3(0,0,0)

@export var spawnPos : Vector3 = Vector3(1020,0,0)
@export var spawnRot : Vector3 = Vector3(0,deg_to_rad(-180),0)

@export var fireTimerMax : float = 5.0
@export var spawnTimerMax : float = 5.0
var fireTimer : float = 0.0
var spawnTimer : float = 0.0

### State Variables ###

@export var rotateTime : float = 3.0
@export var transitionTime : float = 5.0

enum States {IDLE, FIRING, SPAWNING, TRANSITION}

var state : States = States.IDLE
var moveTween
var rotateTween

### Firing Variables ###
var bulletObject = load("res://scenes/bullet.tscn")

@onready var l_targeting = find_child("LeftBarrel")
@onready var l_fire_point = find_child("LeftFirePoint")
@onready var r_targeting = find_child("RightBarrel")
@onready var r_fire_point = find_child("RightFirePoint")

@export var shootTimerMax : float = 0.2
var shootTimer : float = 0.0

### Spawning Variables ###
var enemyObject = load("res://scenes/enemies/enemy_path.tscn")
var leftPath = load("res://flight_paths/boss_left.tres")
var rightPath = load("res://flight_paths/boss_right.tres")

@export var enemyTimerMax : float = 2.0
var enemyTimer : float = 0.0

func _ready():
	_link_signals()
	_choose_destination()
	
	$BossFightStart.start_fight.connect(start)
	
func _physics_process(delta):
	if state == States.IDLE:
		pass
	elif state == States.FIRING:
		fireTimer += delta
		if fireTimer >= fireTimerMax:
			fireTimer = 0
			state = States.TRANSITION
			fire_to_spawn()
			
		shootTimer += delta
		if shootTimer >= shootTimerMax:
			shootTimer = 0
			_shoot(l_fire_point)
			_shoot(r_fire_point)
	elif state == States.TRANSITION:
		pass
	elif state == States.SPAWNING:
		spawnTimer += delta
		if spawnTimer >= spawnTimerMax:
			spawnTimer = 0
			state = States.TRANSITION
			spawn_to_fire()
			
		enemyTimer += delta
		if enemyTimer >= enemyTimerMax:
			enemyTimer = 0
			_spawn()
			
func start():
	state = States.FIRING
		
func fire_to_spawn():
	# cancel the move tween, go to start position, then rotate and move backwards
	if moveTween:
		moveTween.kill()
		
	moveTween = create_tween()
	moveTween.set_trans(Tween.TRANS_EXPO)
	moveTween.set_ease(Tween.EASE_OUT)
	moveTween.tween_property(self, "position", firePos, rotateTime)
	await moveTween.finished
	
	if rotateTween:
		rotateTween.kill()
		
	rotateTween = create_tween()
	rotateTween.tween_property(self, "rotation", spawnRot, rotateTime)
	
	if moveTween:
		moveTween.kill()
	moveTween = create_tween()
	moveTween.tween_property(self, "position", spawnPos, transitionTime)
	await moveTween.finished
	
	state = States.SPAWNING
	
func spawn_to_fire():
	if rotateTween:
		rotateTween.kill()
		
	rotateTween = create_tween()
	rotateTween.tween_property(self, "rotation", fireRot, rotateTime)
	
	if moveTween:
		moveTween.kill()
	moveTween = create_tween()
	moveTween.tween_property(self, "position", firePos, transitionTime)
	await moveTween.finished
	
	state = States.FIRING
	
	_choose_destination()
	
func _shoot(fire_point):
	var bullet = bulletObject.instantiate()
	get_tree().root.get_child(0).add_child(bullet)
	bullet.global_position = fire_point.global_position
	bullet.rotation = fire_point.global_rotation
	bullet.enemyBullet()
	
func _spawn():
	var enemy = enemyObject.instantiate()
	get_tree().root.get_child(0).add_child(enemy)
	enemy.global_position = Vector3(4000,0,0)
	enemy.follow_player = false
	enemy.speed = 35.0
	enemy.activate(null)
	
	var dir = randi_range(0,1)
	if dir == 0:
		enemy.curve = leftPath
	elif dir == 1:
		enemy.curve = rightPath
		
func _choose_destination():
	var standard_array = Array(floatPosArray)
	var valid_options = standard_array.filter(func(pos):return not pos.is_equal_approx(self.position))
	
	if not valid_options.is_empty():
		var next_position : Vector3 = valid_options.pick_random()
		if next_position.y != 0:
			_set_destination("y", next_position.y)
		elif next_position.z != 0:
			_set_destination("z", next_position.z)

func _set_destination(axis : String, pos):
	if moveTween:
		moveTween.kill()
	
	moveTween = create_tween()
	moveTween.set_trans(Tween.TRANS_EXPO)
	moveTween.set_ease(Tween.EASE_OUT)
	if axis == "y":
		moveTween.tween_property(self, "position:y", pos, moveTime)
	elif axis == "z":
		moveTween.tween_property(self, "position:z", pos, moveTime)
	
	moveTween.tween_callback(_choose_destination)
	
func _link_signals():
	for i in get_tree().get_nodes_in_group("BossHit"):
		i.hurt.connect(_hurt)
	
func _hurt(damage, multiplier):
	var damageAmount = damage * multiplier
	
	hp -= damageAmount
	
	print(hp)
