extends Node3D

@onready var debris = $Debris
@onready var smoke = find_child("Smoke")
@onready var fire = find_child("Fire")

func _ready():
	pass

func explode(destroy : bool = true):
	# Debris is always there, but there is an alternate explosion with fire and smoke, hence checking if they exist
	debris.emitting = true
	if is_instance_valid(fire):
		fire.emitting = true
	if is_instance_valid(smoke):
		smoke.emitting = true
	
	if destroy:
		await get_tree().create_timer(2.0).timeout
		queue_free()
