# ui/inventory_ui.gd
extends Control

const PAUSE_TIMER_WHILE_OPEN := false

# Measurements are in pixels of the original 3500x3000 backpack image.
const IMG_SIZE := Vector2(3500, 3000)
const COLUMNS := 5
const SLOT_ORIGIN := Vector2(964, 679)
const SLOT_SIZE_PX := Vector2(290, 268)
const SLOT_STEP := Vector2(323, 402)
const ICON_PADDING := 24.0
const CLOSE_RECT := Rect2(2800, 1250, 340, 260)

@onready var backpack: TextureRect = $Backpack
@onready var slots: Control = $Backpack/Slots
@onready var desc_label: Label = $Backpack/DescLabel
@onready var close_button: Button = $Backpack/CloseButton

var selected_item: ItemData = null


func _ready() -> void:
	hide()
	close_button.pressed.connect(close)
	backpack.resized.connect(_layout_hotspots)
	Inventory.item_added.connect(func(_i): refresh())


func toggle() -> void:
	if visible:
		close()
	else:
		open()


func open() -> void:
	show()
	if PAUSE_TIMER_WHILE_OPEN:
		MinigameTimer.paused = true
	_layout_hotspots()
	refresh()


func close() -> void:
	hide()
	MinigameTimer.paused = false


func _to_screen(r: Rect2) -> Rect2:
	var s := backpack.size / IMG_SIZE
	return Rect2(r.position * s, r.size * s)


func _place(c: Control, image_rect: Rect2) -> void:
	var r := _to_screen(image_rect)
	c.position = r.position
	c.size = r.size


func _layout_hotspots() -> void:
	_place(close_button, CLOSE_RECT)


func refresh() -> void:
	for c in slots.get_children():
		c.queue_free()
	selected_item = null
	desc_label.text = ""

	for i in Inventory.items.size():
		var item: ItemData = Inventory.items[i]
		var rect := Rect2(
			SLOT_ORIGIN + Vector2(i % COLUMNS, i / COLUMNS) * SLOT_STEP,
			SLOT_SIZE_PX
		).grow(-ICON_PADDING)

		var btn := TextureButton.new()
		btn.texture_normal = item.icon
		btn.ignore_texture_size = true
		btn.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		btn.tooltip_text = item.display_name
		_place(btn, rect)
		btn.pressed.connect(_select.bind(item, btn))
		slots.add_child(btn)


func _select(item: ItemData, btn: TextureButton) -> void:
	selected_item = item
	desc_label.text = "%s\n%s" % [item.display_name, item.description]
	for c in slots.get_children():
		c.modulate = Color.WHITE if c == btn else Color(0.65, 0.65, 0.65)
