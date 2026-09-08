extends Area3D

func _ready():
	area_entered.connect(collide)

func destroy():
	EventBus.powerup_activated.emit()
	self.queue_free()

func collide(_area):
	destroy()
