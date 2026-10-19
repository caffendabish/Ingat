extends CharacterBody2D

@export var speed = 400
@export var min_scale = 0.5    # size at the top (far away)
@export var max_scale = 1.5    # size at the bottom (close)
@export var top_y = 200.0      # Y position where he's smallest
@export var bottom_y = 900.0   # Y position where he's biggest
@export var click_stop_distance = 5.0
@export var step_interval = 0.4   # seconds between footstep sounds
@export_range(-40.0, 6.0) var step_db = -6.0
@export_range(0.0, 0.3) var step_pitch_variation = 0.05

@onready var _animated_sprite = $AnimatedSprite2D

var target_position = null
var _step_timer := 0.0

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
		_animated_sprite.play("walkright")
	elif intended_velocity.x < 0:
		_animated_sprite.play("walkleft")
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
	update_steps(delta, moved)

# footsteps: plays while he actually moves (the first step right away, then one per step_interval)
func update_steps(delta: float, moved: Vector2) -> void:
	if moved.length() < 0.5:
		_step_timer = 0.0
		return
	_step_timer -= delta
	if _step_timer <= 0.0:
		AudioManager.play_sfx("step", step_pitch_variation, step_db)
		_step_timer = step_interval
