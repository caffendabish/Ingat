extends CanvasLayer

@onready var timer_label: Label = $TimerLabel
@onready var tint: ColorRect = $ColorRect
@onready var gather_label: Label = $Label


func _ready() -> void:
	tint.mouse_filter = Control.MOUSE_FILTER_IGNORE      # never block clicks on pickups
	timer_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	timer_label.add_theme_font_size_override("font_size", 300)
	timer_label.add_theme_color_override("font_outline_color", Color.BLACK)
	timer_label.add_theme_constant_override("outline_size", 10)
	timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	timer_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	# Gather text setup
	gather_label.text = "G A T H E R   T H E M   A L L . . ."
	gather_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))
	gather_label.add_theme_font_size_override("font_size", 46)
	gather_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	gather_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	gather_label.visible = false

	# Use the SpookworksGame font for the gather text
	var font = load("res://Redundant Assets/SpookworksGame (1).ttf")
	gather_label.add_theme_font_override("font", font)

	# Timer: white color + Spookworks font
	timer_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))
	timer_label.add_theme_font_override("font", font)


func show_gather_text() -> void:
	gather_label.visible = true


func hide_gather_text() -> void:
	gather_label.visible = false


func _process(_delta: float) -> void:
	visible = MinigameTimer.running and GameHUD.hud_enabled
	if not visible:
		return
	var t := int(ceil(MinigameTimer.time_left))
	timer_label.text = "%02d:%02d" % [t / 60, t % 60]

	# Color: white normally, red at 30s or less
	var base_color := Color.WHITE if t > 30 else Color(1.0, 0.35, 0.35, 1.0)

	# Slightly translucent + shaky, centered on screen
	var tick := Time.get_ticks_msec() / 1000.0
	var shake := Vector2(sin(tick * 25.0) * 4.0, cos(tick * 19.0) * 4.0)
	var center := get_viewport().get_visible_rect().size / 2.0
	timer_label.modulate = base_color * 0.45
	timer_label.position = center - (timer_label.size / 2.0) + shake
