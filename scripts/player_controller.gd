extends CharacterBody3D

@export var speed : float = 10.0
@export var margin : float = 0.5

@onready var camera : Camera3D = get_parent()

func _physics_process(delta) -> void:
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var move_dir = Vector3(input_dir.x, -input_dir.y, 0.0)
	
	velocity = move_dir * speed
	move_and_slide()
	
	if camera:
		lock_to_camera()
		
func lock_to_camera() -> void:
	pass
