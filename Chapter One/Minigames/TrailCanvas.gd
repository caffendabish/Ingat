extends Sprite2D

@export var brush_width := 10.0
@export var brush_color := Color(0.25, 0.25, 0.3, 1.0)
@export var min_point_distance := 3.0

var strokes: Array[PackedVector2Array] = []
var current := PackedVector2Array()


func _ready():
	# Ignore any scale/offset set on this node or its parents
	top_level = true
	global_position = Vector2.ZERO
	global_rotation = 0.0
	global_scale = Vector2.ONE
	texture = null


# Takes a WORLD position (the player's global_position)
func stamp(world_pos: Vector2):
	if current.is_empty() or current[current.size() - 1].distance_to(world_pos) >= min_point_distance:
		current.append(world_pos)
		queue_redraw()


func end_stroke():
	if not current.is_empty():
		strokes.append(current)
		current = PackedVector2Array()
		queue_redraw()


func _draw():
	for s in strokes:
		_draw_stroke(s)
	_draw_stroke(current)


func _draw_stroke(s: PackedVector2Array):
	if s.size() == 1:
		draw_circle(s[0], brush_width * 0.5, brush_color)
	elif s.size() > 1:
		draw_polyline(s, brush_color, brush_width, true)
		draw_circle(s[0], brush_width * 0.5, brush_color)
		draw_circle(s[s.size() - 1], brush_width * 0.5, brush_color)
