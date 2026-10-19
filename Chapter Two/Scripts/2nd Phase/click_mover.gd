extends CharacterBody2D

@export var speed := 500.0
@export var arrive_distance := 8.0
@export var min_x := 80.0      # left limit
@export var max_x := 1840.0    # right limit
@export var allow_keys := true # A/D and arrow keys
@export var step_interval := 0.35   # seconds between footstep sounds while walking
@export_range(-40.0, 6.0) var step_db := -6.0
@export_range(0.0, 0.3) var step_pitch_variation := 0.05

var enabled := true
var target_x := 0.0
var moving := false
var lock_y := 0.0
var _step_timer := 0.0

@onready var sprite := get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D


func _ready() -> void:
	lock_y = global_position.y     # Y never changes after this
	target_x = global_position.x


func _unhandled_input(event: InputEvent) -> void:
	if not enabled:
		return
	if event is InputEventMouseButton and event.pressed \
			and event.button_index == MOUSE_BUTTON_LEFT:
		target_x = clampf(get_global_mouse_position().x, min_x, max_x)
		moving = true


func _physics_process(_delta: float) -> void:
	if not enabled:
		_step_timer = 0.0
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var dir := 0.0

	# keys override a click target
	if allow_keys:
		dir = Input.get_axis("ui_left", "ui_right")
		if Input.is_key_pressed(KEY_A):
			dir -= 1.0
		if Input.is_key_pressed(KEY_D):
			dir += 1.0
		dir = clampf(dir, -1.0, 1.0)
		if dir != 0.0:
			moving = false

	# otherwise walk toward the clicked x
	if dir == 0.0 and moving:
		var dx := target_x - global_position.x
		if absf(dx) <= arrive_distance:
			moving = false
		else:
			dir = signf(dx)

	velocity = Vector2(dir * speed, 0.0)
	move_and_slide()

	# hard locks: no vertical drift, never leave the walking range
	global_position.y = lock_y
	global_position.x = clampf(global_position.x, min_x, max_x)

	if sprite and dir != 0.0:
		sprite.flip_h = dir < 0.0   # assumes the art faces right
