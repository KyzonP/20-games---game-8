extends Node3D

@export var hp : float = 50.0
@export var speed : float = 15.0

@export var moveTime : float = 5.0

@export var floatPosArray : PackedVector3Array = [
	Vector3(1000,50,0),
	Vector3(1000,-50,0),
	Vector3(1000,0,50),
	Vector3(1000,0,-50)
]

@export var firePos : Vector3 = Vector3(980,0,0)
@export var fireRot : Vector3 = Vector3(0,0,0)

@export var spawnPos : Vector3 = Vector3(1020,0,0)
@export var spawnRot : Vector3 = Vector3(0,-180,0)

enum States {IDLE, FIRING, SPAWNING}

var state : States = States.IDLE

func _ready():
	_link_signals()
	_choose_destination()
	
func _physics_process(delta):
	if state == States.IDLE:
		pass
	elif state == States.FIRING:
		pass
	elif state == States.SPAWNING:
		pass
		
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
	var moveTween = create_tween()
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
