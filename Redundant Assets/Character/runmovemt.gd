extends CharacterBody2D

@export var speed = 400
@export var min_scale = 0.5    # size at the top (far away)
@export var max_scale = 1.5    # size at the bottom (close)
@export var top_y = 200.0      # Y position where he's smallest
@export var bottom_y = 900.0   # Y position where he's biggest
@export var click_stop_distance = 5.0

@onready var _animated_sprite = $AnimatedSprite2D

var target_position = null

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var click = get_global_mouse_position()
		click.y = clamp(click.y, top_y, bottom_y)
		target_position = click

func get_input():
	var input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	if input_direction != Vector2.ZERO:
		target_position = null
		velocity = input_direction * speed
	elif target_position != null:
		var direction = target_position - global_position
		if direction.length() > click_stop_distance:
			velocity = direction.normalized() * speed
		else:
			velocity = Vector2.ZERO
			target_position = null
	else:
		velocity = Vector2.ZERO

func update_animation(intended_velocity: Vector2, moved: Vector2):
	if moved.length() < 0.5:
		_animated_sprite.play("idle")
	elif intended_velocity.x > 0:
		_animated_sprite.play("runr")
	elif intended_velocity.x < 0:
		_animated_sprite.play("runl")
	else:
		_animated_sprite.play("idle")

func update_scale():
	var t = inverse_lerp(top_y, bottom_y, global_position.y)
	t = clamp(t, 0.0, 1.0)
	var s = lerp(min_scale, max_scale, t)
	scale = Vector2(s, s)

func _physics_process(delta):
	get_input()
	var intended_velocity = velocity
	var old_pos = global_position

	move_and_slide()
	global_position.y = clamp(global_position.y, top_y, bottom_y)

	var moved = global_position - old_pos

	# Give up on a click target if he's blocked
	if target_position != null and moved.length() < 0.5:
		target_position = null

	update_animation(intended_velocity, moved)
	update_scale()
