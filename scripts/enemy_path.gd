extends Path3D

var enemies : Array[Node] = []
## How many enemies are instantiated
@export var enemyCount : int = 1
## Distance between additional enemies
@export var transform_range : float = 10.0
## Speed of enemies
@export var speed : float = 10.0
## If the path goes 'around' the player
@export var follow_player : bool = false

var end_margin : float = 0.01
var active : bool = false

@onready var pathFollow = find_child("PathFollow3D")
## Direction additional enemies spawn
@export_enum("Diagonal", "Horizontal", "Vertical") var pattern_shape : String
## If enemy rotates to face player while flying
@export var enemyTarget : bool = true

# Enemies
var flying_enemy = load("res://scenes/enemies/flying_enemy.tscn")
	
func _ready() -> void:
	$Area3D.area_entered.connect(activate)
	
func _physics_process(delta) -> void:
	if active:
		pathFollow.progress += delta * speed
		
		if pathFollow.progress_ratio > 0.92:
			_end_path()
	
func _spawn_enemies() -> void:
	var transform_mod = 0.0
	for i in enemyCount:
		var enemy = flying_enemy.instantiate()
		pathFollow.add_child(enemy)
		
		if pattern_shape == "Diagonal":
			enemy.position = Vector3(0, transform_mod, transform_mod)
		elif pattern_shape == "Vertical":
			enemy.position = Vector3(0, transform_mod, 0)
		elif pattern_shape == "Horizontal":
			enemy.position = Vector3(0,0,transform_mod)
			
		transform_mod += transform_range
		
		# add to array
		enemies.append(enemy)
		
		# connect signal
		if enemy.has_signal("defeated"):
			enemy.defeated.connect(_on_enemy_defeated)
			
		# disable if checked
		if not enemyTarget:
			enemy.disable_rotation()
		
func _on_enemy_defeated(enemy_node) -> void:
	enemies.erase(enemy_node)
	
	if enemies.is_empty():
		_end_path()
		
func _end_path() -> void:
	self.queue_free()
	
func activate(_area) -> void:
	if not active:
		_spawn_enemies()
		active = true
		
		if follow_player:
			self.reparent.call_deferred(_area.get_parent(), true)
