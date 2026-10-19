# pick_up.gd (attach to the PickUp Area2D)
extends Area2D

@export var item: ItemData
@export var pickup_id: StringName        # must be unique per pickup in the game
@export var display_size: float = 64.0   # on-screen size of the item, change per pickup if needed

@export_group("Outline")
@export var outline_color: Color = Color(1.0, 1.0, 1.0, 1.0)   # full white outline
@export var outline_speed: float = 2.0                            # pulses per second
@export var outline_alpha_min: float = 0.3                        # dimmest alpha
@export var outline_alpha_max: float = 1.0                        # full white at brightest
@export var outline_thickness_min: float = 0.04                   # thinnest outline
@export var outline_thickness_max: float = 0.10                   # thickest outline
@export var outline_glow: float = 0.02                            # soft outer glow radius
@export var outline_scale_pulse: float = 1.1                      # scale multiplier at brightest

var _outline: Sprite2D
var _base_outline_scale: Vector2


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

	# 3.5. Set up the pulsing outline behind the icon
	var outline := get_node_or_null("Outline") as Sprite2D
	_outline = outline
	if _outline and item.icon:
		_outline.texture = item.icon
		var tex_size: Vector2 = item.icon.get_size()
		var icon_scale: float = display_size / max(tex_size.x, tex_size.y)
		# Make it slightly larger than the icon so the outline peeks out around it
		_base_outline_scale = Vector2.ONE * icon_scale * 1.08
		_outline.scale = _base_outline_scale
		_outline.modulate = outline_color
		_outline.modulate.a = outline_alpha_min

		# Set shader uniforms via the material
		var mat := _outline.material as ShaderMaterial
		if mat:
			mat.set_shader_parameter("texture_size", tex_size)
			mat.set_shader_parameter("outline_thickness", outline_thickness_min)
			mat.set_shader_parameter("glow", outline_glow)

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

func _process(delta: float) -> void:
	if _outline:
		# Smooth pulse from 0..1 over time
		var pulse = (sin(Time.get_ticks_msec() / 1000.0 * outline_speed) + 1.0) / 2.0
		_outline.modulate.a = lerp(outline_alpha_min, outline_alpha_max, pulse)

		# Pulse outline thickness and glow
		var mat := _outline.material as ShaderMaterial
		if mat:
			mat.set_shader_parameter("outline_thickness", lerp(outline_thickness_min, outline_thickness_max, pulse))
			mat.set_shader_parameter("glow", lerp(outline_glow * 0.5, outline_glow, pulse))

		# Pulse scale slightly so it "breathes" around the icon
		_outline.scale = _base_outline_scale * lerp(1.0, outline_scale_pulse, pulse)
