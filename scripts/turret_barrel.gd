extends CSGSphere3D

signal playerFound
signal playerLost

@export var target : Marker3D

@export var speed : float = 2.5

@export var detect_range : float = 160.0

@export var turn_range : float = 250.0

var within_range : bool = false

var disabled : bool = false

func _ready():
	EventBus.give_player.connect(_set_target)

func _physics_process(delta):
	if is_instance_valid(target):
		if not disabled and within_range:
			_rotate_towards(delta)
		
		_detect_target()
	else:
		EventBus.request_player.emit()
	
func disable():
	disabled = true
	
func enable():
	disabled = false
	
func _detect_target() -> void:
	var forward_dir = global_transform.basis.z
	var target_dir = (target.global_position - global_position).normalized()
	
	var angle_radians = forward_dir.angle_to(target_dir)
	var angle_degrees = rad_to_deg(angle_radians)
	
	if angle_degrees >= detect_range:
		playerFound.emit()
	else:
		playerLost.emit()
		
	if not within_range and self.global_position.distance_to(target.global_position) <= turn_range:
		within_range = true
	
func _rotate_towards(delta) -> void:
	var current_rot = Quaternion(transform.basis)
	look_at(target.global_position, Vector3.UP)
	var target_rot = Quaternion(transform.basis)
	
	var smooth_rot = current_rot.slerp(target_rot, speed * delta)
	
	transform.basis = Basis(smooth_rot)

func _set_target(player) -> void:
	target = player
