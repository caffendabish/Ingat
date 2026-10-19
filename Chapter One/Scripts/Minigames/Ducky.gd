class_name Ducky
extends CharacterBody2D

@export var speed := 400.0
@export var follow_deadzone := 4.0
@export var debug_print := true
@export var ignore_walls_test := false  # walls are ON again

@onready var trail = %TrailCanvas

var screen_target: Vector2
var is_holding := false
var can_drag := false   # set to true by duck_act.gd after the intro dialogue ends


func _ready():
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	if ignore_walls_test:
		collision_mask = 0


func _input(event):
	if not can_drag:
		return
	if event is InputEventScreenTouch:
		is_holding = event.pressed
		screen_target = event.position
		if not is_holding:
			trail.end_stroke()
	elif event is InputEventScreenDrag:
		screen_target = event.position
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		is_holding = event.pressed
		screen_target = event.position
		if not is_holding:
			trail.end_stroke()
	elif event is InputEventMouseMotion and is_holding:
		screen_target = event.position


func _physics_process(_delta):
	if not is_holding:
		velocity = Vector2.ZERO
		return

	var world_target: Vector2 = get_canvas_transform().affine_inverse() * screen_target
	var to_target := world_target - global_position

	if to_target.length() > follow_deadzone:
		velocity = to_target.normalized() * speed
	else:
		velocity = Vector2.ZERO

	move_and_slide()

	if debug_print and get_slide_collision_count() > 0:
		var hit = get_slide_collision(0).get_collider()
		print("hit: ", hit.name if hit else "unknown")

	trail.stamp(global_position)
