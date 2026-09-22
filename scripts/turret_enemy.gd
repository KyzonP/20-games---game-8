extends Area3D

## HP of enemy
@export var hp : float = 1.0
## Reload time of enemy
@export var fire_rate : float = 1.0
## Distance at which enemy fires
@export var fire_distance : float = 100.0
## Score from defeating enemy
@export var points_value : int = 10
## If it's a background turret/shooting Aremag
@export var lock : bool = false
@onready var fire_timer : float = 1.0
var target : Marker3D
var shooting : bool = false

@onready var fire_point = find_child("FirePoint")
@onready var targeting = find_child("Targeting")

signal defeated(enemy_node)

# Bullets
var bulletObject = load("res://scenes/bullet.tscn")

func _ready():
	area_entered.connect(collide)
	targeting.playerFound.connect(_enable_shooting)
	targeting.playerLost.connect(_disable_shooting)
	EventBus.give_player.connect(_set_target)
	EventBus.bomb_activated.connect(_bomb_check)
	
	EventBus.request_player.emit()
	
	if lock:
		disable_rotation()
	
func disable_rotation():
	targeting.disable()

func _physics_process(delta):
	if not lock:
		if is_instance_valid(target):
			if global_position.distance_to(target.global_position) <= fire_distance and shooting:
				fire_timer += delta
		else:
			EventBus.request_player.emit()
		#
		if fire_timer >= fire_rate:
			fire_timer = 0.0
			_shoot()
	else:
		fire_timer += delta
		if fire_timer >= fire_rate:
			fire_timer = 0.0
			_shoot()

func _shoot():
	var bullet = bulletObject.instantiate()
	get_tree().root.get_child(0).add_child(bullet)
	bullet.global_position = fire_point.global_position
	bullet.rotation = fire_point.global_rotation
	bullet.enemyBullet()
	
func destroy():
	defeated.emit(self)
	EventBus.score_increased.emit(points_value)
	queue_free()
	
func collide(_area):
	destroy()
	
func _set_target(player):
	target = player
	
func _enable_shooting():
	shooting = true
	
func _disable_shooting():
	shooting = false
	
func _bomb_check(pos, distance):
	if pos.distance_to(global_position) < distance:
		destroy()
