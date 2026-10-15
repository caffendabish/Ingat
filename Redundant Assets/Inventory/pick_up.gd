# pick_up.gd (attach to the PickUp Area2D)
extends Area2D

@export var item: ItemData
@export var pickup_id: StringName        # must be unique per pickup in the game
@export var display_size: float = 64.0   # on-screen size of the item, change per pickup if needed


func _ready() -> void:
	# 1. Safety check: warn if the Item slot was left empty
	if item == null:
		push_warning("Pickup '%s' has no Item assigned!" % name)
		return

	# 2. If already collected, remove it so it doesn't come back
	if pickup_id in GameState.collected_pickups:
		queue_free()
		return

	# 3. Show and scale the icon (only if this pickup has a Sprite2D)
	var sprite := get_node_or_null("Sprite2D") as Sprite2D
	if sprite and item.icon:
		sprite.texture = item.icon
		var tex_size := item.icon.get_size()
		sprite.scale = Vector2.ONE * (display_size / max(tex_size.x, tex_size.y))

	# 4. Hand cursor on hover
	mouse_entered.connect(func(): Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND))
	mouse_exited.connect(func(): Input.set_default_cursor_shape(Input.CURSOR_ARROW))

	# 5. Listen for clicks
	input_event.connect(_on_input_event)


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed \
			and event.button_index == MOUSE_BUTTON_LEFT:
		if Inventory.add_item(item):
			GameState.collected_pickups.append(pickup_id)
			Input.set_default_cursor_shape(Input.CURSOR_ARROW)
			queue_free()
