extends CanvasLayer

@onready var timer_label: Label = $TimerLabel
@onready var tint: ColorRect = $ColorRect


func _ready() -> void:
	tint.mouse_filter = Control.MOUSE_FILTER_IGNORE      # never block clicks on pickups
	timer_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	timer_label.add_theme_font_size_override("font_size", 300)
	timer_label.add_theme_color_override("font_outline_color", Color.BLACK)
	timer_label.add_theme_constant_override("outline_size", 10)
	timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	timer_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER


func _process(_delta: float) -> void:
	visible = MinigameTimer.running and GameHUD.hud_enabled
	if not visible:
		return
	var t := int(ceil(MinigameTimer.time_left))
	timer_label.text = "%02d:%02d" % [t / 60, t % 60]
	# last 30 seconds turn red
	timer_label.modulate = Color(1, 0.35, 0.35) if t <= 30 else Color.WHITE
