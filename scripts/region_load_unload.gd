extends Node3D

@export var next_region : Node3D


var entered : bool = false

func _ready():
	call_deferred("_connect_signals")
	
func _connect_signals():
	if $Start and $End:
		$Start.area_entered.connect(load_next_region)
		$End.area_entered.connect(unload_region)
		print("Signals connected")
	else:
		print("Broke")
		if not $Start:
			print("No start")
		elif not $End:
			print("No end")

func unload_region(_area):
	print("Unloading previous region")
	self.queue_free()
	
func load_next_region(_area):
	print("Loading next region")
	if not entered:
		entered = true
		
		if is_instance_valid(next_region):
			next_region.process_mode = Node.PROCESS_MODE_INHERIT
			next_region.visible = true
