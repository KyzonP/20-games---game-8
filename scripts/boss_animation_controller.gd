extends Node3D

@export var time_in_seconds : float = 0.5

@export var upper_leg : Array[MeshInstance3D] = []
@export var middle_leg : Array[MeshInstance3D] = []
@export var lower_leg : Array[MeshInstance3D] = []

@onready var left_wing = find_child("left_wing-col2")
@onready var right_wing = find_child("right_wing-col2")

var leftTween

var rightTween

func legs_appear():
	for i in upper_leg:
		i.visible = true
	await get_tree().create_timer(time_in_seconds).timeout
	for i in middle_leg:
		i.visible = true
	await get_tree().create_timer(time_in_seconds).timeout
	for i in lower_leg:
		i.visible = true
	
func legs_vanish():
	for i in upper_leg:
		i.visible = false
	await get_tree().create_timer(time_in_seconds).timeout
	for i in middle_leg:
		i.visible = false
	await get_tree().create_timer(time_in_seconds).timeout
	for i in lower_leg:
		i.visible = false
		
func wings_close():
	if leftTween:
		leftTween.kill()
	leftTween = create_tween()
	leftTween.set_trans(Tween.TRANS_EXPO)
	leftTween.set_ease(Tween.EASE_OUT)
	leftTween.tween_property(left_wing, "rotation", Vector3(0,0,0), time_in_seconds)
	if rightTween:
		rightTween.kill()
	rightTween = create_tween()
	rightTween.set_trans(Tween.TRANS_EXPO)
	rightTween.set_ease(Tween.EASE_OUT)
	rightTween.tween_property(right_wing, "rotation", Vector3(0,0,0), time_in_seconds)
	
func wings_open():
	if leftTween:
		leftTween.kill()
	leftTween = create_tween()
	leftTween.set_trans(Tween.TRANS_EXPO)
	leftTween.set_ease(Tween.EASE_OUT)
	leftTween.tween_property(left_wing, "rotation", Vector3(deg_to_rad(25),0,deg_to_rad(75)), time_in_seconds)
	
	if rightTween:
		rightTween.kill()
	rightTween = create_tween()
	rightTween.set_trans(Tween.TRANS_EXPO)
	rightTween.set_ease(Tween.EASE_OUT)
	rightTween.tween_property(right_wing, "rotation", Vector3(deg_to_rad(-25),0,deg_to_rad(75)), time_in_seconds)
