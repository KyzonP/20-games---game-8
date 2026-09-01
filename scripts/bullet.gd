extends Area3D

@export var speed : float = 1.0

func _ready():
	area_entered.connect(collide)	
	
	$Timer.timeout.connect(destroy)
	
func playerBullet():
	set_collision_layer_value(2, true)
	
func enemyBullet():
	set_collision_layer_value(4, true)
	set_collision_mask_value(1, true)
	set_collision_mask_value(2, true)

func _physics_process(_delta):
	position += global_transform.basis * Vector3(0,0,-speed)
	
	if global_position.y <= 0:
		destroy()

func destroy():
	queue_free()

func collide(_area):
	destroy()
