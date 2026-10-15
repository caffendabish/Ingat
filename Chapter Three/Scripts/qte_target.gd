extends Control

signal hit
signal missed

# Look: change these to match your game's style
var circle_color := Color("a8813cff")
var outline_color := Color.WHITE
var ring_color := Color.WHITE
var ring_width := 4.0
var number_color := Color.WHITE

# State
var radius := 40.0
var shrink_time := 1.0
var number := 1
var ring_scale := 3.0   # ring starts at 3x the circle's radius
var resolved := false

func setup(size_px: float, time: float, num: int) -> void:
	radius = size_px / 2.0
	shrink_time = time
	number = num
	size = Vector2(size_px, size_px)

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP

	# Animate ring_scale from 3.0 down to 1.0
	var tween := create_tween()
	tween.tween_property(self, "ring_scale", 1.0, shrink_time)
	tween.finished.connect(_on_time_up)

func _process(_delta: float) -> void:
	queue_redraw()   # redraw every frame so the ring animates

func _draw() -> void:
	var center := size / 2.0

	# Filled circle + outline
	draw_circle(center, radius, circle_color)
	draw_arc(center, radius, 0.0, TAU, 64, outline_color, 3.0, true)

	# Approach ring (shrinks onto the circle)
	draw_arc(center, radius * ring_scale, 0.0, TAU, 96, ring_color, ring_width, true)

	# Number in the middle
	var font := ThemeDB.fallback_font
	var font_size := int(radius * 0.8)
	var text := str(number)
	var text_size := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
	var baseline := Vector2(
		center.x - text_size.x / 2.0,
		center.y - text_size.y / 2.0 + font.get_ascent(font_size)
	)
	draw_string(font, baseline, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, number_color)

func _gui_input(event: InputEvent) -> void:
	if resolved:
		return
	if event is InputEventMouseButton and event.pressed \
	and event.button_index == MOUSE_BUTTON_LEFT:
		# Only count clicks inside the actual circle, not the square corners
		if event.position.distance_to(size / 2.0) <= radius:
			resolved = true
			hit.emit()
			queue_free()

func _on_time_up() -> void:
	if resolved:
		return
	resolved = true
	missed.emit()
	queue_free()
