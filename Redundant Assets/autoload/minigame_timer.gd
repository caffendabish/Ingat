extends Node

signal time_up
signal inventory_complete  # emitted when all 10 items are gathered

const DEFAULT_TIME := 60.0
const REQUIRED_ITEMS := 10
const GATHER_MOVE_INTERVAL := 1.5   # seconds between random jumps
const TICK_DB := -8.0               # tick-tock volume while the clock runs
const TICK_FADE_IN := 0.5
const TICK_FADE_OUT := 0.3

var time_left: float = 0.0
var running := false
var paused := false
var finished := false   # becomes true once the countdown runs out OR inventory is full
var _inventory_proceeded := false

var _gather_base_pos: Vector2
var _gather_move_timer: float = 0.0


func _ready() -> void:
	Inventory.item_added.connect(_on_item_added)

func start(seconds: float = DEFAULT_TIME) -> void:
	time_left = seconds
	running = true
	paused = false
	finished = false
	_inventory_proceeded = false
	_gather_move_timer = 0.0
	AudioManager.play_layer("ticktock", "ticktock", TICK_DB, TICK_FADE_IN)

	# Show the spooky gather text for the whole minigame sequence
	MinigameHud.show_gather_text()
	_gather_base_pos = _pick_random_gather_position()
	MinigameHud.gather_label.position = _gather_base_pos

# Pick a random on-screen spot for the gather text (kept inside the viewport with margins)
func _pick_random_gather_position() -> Vector2:
	var vp_size = get_viewport().get_visible_rect().size
	var label: Label = MinigameHud.gather_label
	var margin_x := 120.0
	var margin_y := 100.0
	var max_x = vp_size.x - label.size.x - margin_x * 2
	var max_y = vp_size.y - label.size.y - margin_y * 2
	var x = randf_range(margin_x, margin_x + max_x)
	var y = randf_range(margin_y, margin_y + max_y)
	return Vector2(x, y)

# Safe to call from EVERY room. It only starts the clock once, and never
# restarts it after it has finished.
func ensure_started(seconds: float = DEFAULT_TIME) -> void:
	if running or finished:
		return
	start(seconds)

# Clears everything, for a new game or a new minigame
func reset() -> void:
	running = false
	paused = false
	finished = false
	_inventory_proceeded = false
	time_left = 0.0
	MinigameHud.hide_gather_text()
	AudioManager.stop_layer("ticktock", TICK_FADE_OUT)

func stop() -> void:
	running = false
	paused = false
	AudioManager.stop_layer("ticktock", TICK_FADE_OUT)

func _on_item_added(_item: ItemData) -> void:
	if finished or Inventory.items.size() >= REQUIRED_ITEMS:
		return
	# Label stays visible throughout; nothing extra needed on pickup

func _proceed_to_next_scene() -> void:
	if _inventory_proceeded or finished:
		return
	_inventory_proceeded = true
	finished = true
	running = false
	MinigameHud.hide_gather_text()
	AudioManager.stop_layer("ticktock", TICK_FADE_OUT)
	inventory_complete.emit()
	SceneFlow._go(SceneFlow.AFTER_MINIGAME)

func _process(delta: float) -> void:
	if not running or paused:
		return
	time_left -= delta

	# Spooky flicker + shake + random jumps on the gather text
	var gather_label: Label = MinigameHud.gather_label
	if gather_label.visible:
		# Jump to a new random spot + new phrase every interval
		_gather_move_timer += delta
		if _gather_move_timer >= GATHER_MOVE_INTERVAL:
			_gather_move_timer = 0.0
			_gather_base_pos = _pick_random_gather_position()
			MinigameHud._set_random_phrase()

		# Spooky pulse: erratic alpha flicker that speeds up as time runs out
		var t = Time.get_ticks_msec() / 1000.0
		var panic: float = 1.0 - clamp(time_left / DEFAULT_TIME, 0.0, 1.0)
		var pulse_speed: float = 6.0 + panic * 14.0
		gather_label.modulate.a = 0.3 + 0.7 * sin(t * pulse_speed)
		var shake_x = sin(t * 28.0 + panic * 10.0) * 5.0
		var shake_y = cos(t * 21.0 + panic * 8.0) * 5.0
		gather_label.position = _gather_base_pos + Vector2(shake_x, shake_y)

	# If the bag is full (10 items), push to the next scene immediately
	if Inventory.items.size() >= REQUIRED_ITEMS:
		_proceed_to_next_scene()
		return

	if time_left <= 0.0:
		time_left = 0.0
		running = false
		finished = true
		MinigameHud.hide_gather_text()
		AudioManager.stop_layer("ticktock", TICK_FADE_OUT)
		time_up.emit()
