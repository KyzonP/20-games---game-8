extends CSGSphere3D

signal playerFound
signal playerLost

@export var target : Area3D

@export var speed : float = 2.5

@export var detect_range : float = 160.0

func _ready():
	EventBus.give_player.connect(_set_target)

func _physics_process(delta):
	_rotate_towards(delta)
	
	_detect_target()
	
func _detect_target() -> void:
	var forward_dir = global_transform.basis.z
	var target_dir = (target.global_position - global_position).normalized()
	
	var angle_radians = forward_dir.angle_to(target_dir)
	var angle_degrees = rad_to_deg(angle_radians)
	
	if angle_degrees >= detect_range:
		playerFound.emit()
	else:
		playerLost.emit()
	
func _rotate_towards(delta) -> void:
	var current_rot = Quaternion(transform.basis)
	look_at(target.global_position, Vector3.UP)
	var target_rot = Quaternion(transform.basis)
	
	var smooth_rot = current_rot.slerp(target_rot, speed * delta)
	
	transform.basis = Basis(smooth_rot)

func _set_target(player) -> void:
	target = player
