extends Area3D

@export var hp : float = 1.0
@export var speed : float = 5.0
@export var fire_rate : float = 1.0
@export var fire_distance : float = 100.0
var fire_timer : float = 0.0
var target : Area3D
var shooting : bool = false

@onready var fire_point = find_child("FirePoint")
@onready var targeting = find_child("Targeting")

# Bullets
var bulletObject = load("res://scenes/bullet.tscn")

func _ready():
	area_entered.connect(collide)
	targeting.playerFound.connect(_enable_shooting)
	targeting.playerLost.connect(_disable_shooting)
	EventBus.give_player.connect(_set_target)

func _physics_process(delta):
	if global_position.distance_to(target.global_position) <= fire_distance and shooting:
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
	queue_free()

func collide(_area):
	destroy()
	
func _set_target(player):
	target = player
	
func _enable_shooting():
	shooting = true
	
func _disable_shooting():
	shooting = false
