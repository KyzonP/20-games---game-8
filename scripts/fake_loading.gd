extends Node3D

### Firing Variables ###
var bulletObject = load("res://scenes/bullet.tscn")
@onready var player = find_child("Player")

func _ready():
	await get_tree().create_timer(2.0).timeout
	
	player.fireBullet()
	
	var bullet = bulletObject.instantiate()
	get_tree().root.get_child(3).add_child(bullet)
	bullet.global_position = Vector3(0,10,-30)
	bullet.destroy()
	
	await get_tree().create_timer(2.0).timeout
	
	get_tree().change_scene_to_file("res://scenes/menu/main_menu.tscn")
