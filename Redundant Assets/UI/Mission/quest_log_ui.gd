extends Control

# Measurements are in pixels of the original 1920x1080 notebook image.
const IMG_SIZE := Vector2(1920, 1080)
const LEFT_PAGE := Rect2(265, 200, 665, 700)
const RIGHT_PAGE := Rect2(1040, 200, 650, 700)

const INK := Color(0.16, 0.18, 0.35)        # dark blue pen
const INK_DONE := Color(0.5, 0.52, 0.65)    # faded for finished quests
const FONT_SIZE := 26

@onready var dim: ColorRect = $Dim
@onready var notebook: TextureRect = $Notebook
@onready var quest_list: VBoxContainer = $Notebook/QuestList
@onready var details: VBoxContainer = $Notebook/Details
@onready var title_label: Label = $Notebook/Details/TitleLabel
@onready var desc_label: Label = $Notebook/Details/DescLabel
@onready var objectives_label: RichTextLabel = $Notebook/Details/ObjectivesLabel

var selected_id: StringName = &""


func _ready() -> void:
	hide()
	_set_area(quest_list, LEFT_PAGE)
	_set_area(details, RIGHT_PAGE)
	_style_text()

	dim.gui_input.connect(_on_dim_input)
	QuestLog.quest_added.connect(func(_id): _refresh_if_open())
	QuestLog.quest_updated.connect(func(_id): _refresh_if_open())
	QuestLog.quest_completed.connect(func(_id): _refresh_if_open())


func toggle() -> void:
	if visible:
		close()
	else:
		open()


func open() -> void:
	show()
	refresh()


func close() -> void:
	hide()


# Esc closes the notebook
func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()


# Clicking the dark area outside the notebook closes it
func _on_dim_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed \
			and event.button_index == MOUSE_BUTTON_LEFT:
		close()


# Pins a node to a rectangle of the original image, scaling with the notebook
func _set_area(c: Control, image_rect: Rect2) -> void:
	c.anchor_left = image_rect.position.x / IMG_SIZE.x
	c.anchor_top = image_rect.position.y / IMG_SIZE.y
	c.anchor_right = image_rect.end.x / IMG_SIZE.x
	c.anchor_bottom = image_rect.end.y / IMG_SIZE.y
	c.offset_left = 0
	c.offset_top = 0
	c.offset_right = 0
	c.offset_bottom = 0


func _style_text() -> void:
	title_label.add_theme_color_override("font_color", INK)
	title_label.add_theme_font_size_override("font_size", FONT_SIZE + 8)

	desc_label.add_theme_color_override("font_color", INK)
	desc_label.add_theme_font_size_override("font_size", FONT_SIZE - 2)
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	objectives_label.bbcode_enabled = true
	objectives_label.fit_content = true
	objectives_label.scroll_active = false
	objectives_label.add_theme_color_override("default_color", INK)
	objectives_label.add_theme_font_size_override("normal_font_size", FONT_SIZE)


func _refresh_if_open() -> void:
	if visible:
		refresh()


func refresh() -> void:
	for c in quest_list.get_children():
		c.queue_free()

	if QuestLog.quests.is_empty():
		title_label.text = "Nothing written yet..."
		desc_label.text = ""
		objectives_label.text = ""
		return

	if not QuestLog.quests.has(selected_id):
		selected_id = QuestLog.quests.keys()[0]

	for id in QuestLog.quests:
		var q: Dictionary = QuestLog.quests[id]
		var btn := Button.new()
		btn.flat = true
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.text = ("> " if id == selected_id else "") + ("[x] " if q.completed else "") + q.title
		var color := INK_DONE if q.completed else INK
		btn.add_theme_color_override("font_color", color)
		btn.add_theme_color_override("font_hover_color", color)
		btn.add_theme_color_override("font_pressed_color", color)
		btn.add_theme_font_size_override("font_size", FONT_SIZE)
		btn.pressed.connect(_select.bind(id))
		quest_list.add_child(btn)

	_show_details(selected_id)


func _select(id: StringName) -> void:
	selected_id = id
	refresh()


func _show_details(id: StringName) -> void:
	var q: Dictionary = QuestLog.quests[id]
	title_label.text = q.title
	desc_label.text = q.description

	var text := ""
	for o in q.objectives:
		if o.done:
			text += "[color=#8a8ca6][s][ x ] %s[/s][/color]\n" % o.text
		else:
			text += "[ ] %s\n" % o.text
	objectives_label.text = text
