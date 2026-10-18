extends Control

signal qte_finished(won: bool)

# CHANGE THIS to the real path of your QTETarget scene
const TARGET_SCENE := preload("res://Chapter Three/Minigames/QTETarget.tscn")

# CHANGE THESE to the real `id` values of your two signaling ItemData resources
const SIGNAL_ITEM_IDS: Array[StringName] = [&"torch", &"whistle"]

const SETTINGS := {
	"hard":   {"targets": 15, "shrink": 0.8, "size": 60.0,  "time": 15.0},
	"normal": {"targets": 12, "shrink": 1.1, "size": 80.0,  "time": 18.0},
	"easy":   {"targets": 8,  "shrink": 1.5, "size": 100.0, "time": 20.0},
}

# Shouting phrases to get rescuers' attention
const SHOUT_PHRASES := [
	"HELP US!",
	"OVER HERE!",
	"RESCUE US!",
	"WE'RE IN HERE!",
	"PLEASE HELP!",
	"IS ANYONE THERE!",
	"HURRY!",
	"DON'T LEAVE US!",
	"COME BACK!",
	"WE NEED HELP!",
]

# Jumpscare pictures shown when a target is missed (assigned in Inspector)
@export var jumpscare_textures: Array[Texture2D] = []

# Tick this in the Inspector to test the scene alone with F6
@export var auto_start := false

@onready var container: Control = $TargetContainer
@onready var time_label: Label = $TimerLabel
@onready var progress_label: Label = $ProgressLabel
@onready var time_limit: Timer = $TimeLimit
@onready var shout_label: Label = $ShoutLabel
@onready var jumpscare_image: TextureRect = $JumpscareImage
@onready var flash_overlay: ColorRect = $FlashOverlay

var cfg: Dictionary
var hits := 0
var finished := true   # stays idle until start() is called
var shout_timer := 0.0
var shout_interval := 2.5   # seconds between random shouts


func _ready() -> void:
	time_limit.one_shot = true
	time_limit.timeout.connect(_on_time_limit)
	GameHUD.hide_hud()
	shout_label.visible = false
	jumpscare_image.visible = false
	flash_overlay.color.a = 0.0


# Counts how many of the signaling items the player owns
func get_signal_item_count() -> int:
	var count := 0
	for id in SIGNAL_ITEM_IDS:
		if Inventory.has_item(id):
			count += 1
	return count

# 0 items = hard, 1 item = normal, 2 items = easy
func get_difficulty_from_inventory() -> String:
	match get_signal_item_count():
		0: return "hard"
		1: return "normal"
		_: return "easy"

# Call start() with no argument to use the inventory,
# or pass "hard" / "normal" / "easy" to force one.
func start(difficulty: String = "") -> void:
	if difficulty == "":
		difficulty = get_difficulty_from_inventory()

	print("QTE signal items: ", get_signal_item_count(), " -> ", difficulty)

	cfg = SETTINGS[difficulty]
	hits = 0
	finished = false
	time_limit.wait_time = cfg["time"]
	time_limit.start()
	_update_progress()
	_spawn_target()
	shout_timer = 0.0
	_shout_random()


func _process(_delta: float) -> void:
	if not finished:
		time_label.text = "%.1f" % time_limit.time_left

		# Random shouting during the QTE
		shout_timer += _delta
		if shout_timer >= shout_interval:
			shout_timer = 0.0
			shout_interval = randf_range(1.5, 4.0)
			_shout_random()


func _spawn_target() -> void:
	if finished:
		return

	var size_px: float = cfg["size"]
	var t = TARGET_SCENE.instantiate()
	container.add_child(t)
	t.setup(size_px, cfg["shrink"], hits + 1)

	# Keep the circle AND its approach ring fully on screen
	var margin := size_px * 1.5
	var area := container.size
	var center := Vector2(
		randf_range(margin, area.x - margin),
		randf_range(margin, area.y - margin)
	)
	t.position = center - t.size / 2.0

	t.hit.connect(_on_target_hit)
	t.missed.connect(_on_target_missed)


func _on_target_hit() -> void:
	hits += 1
	_update_progress()
	if hits >= cfg["targets"]:
		_end(true)
	else:
		_spawn_target()


func _on_target_missed() -> void:
	# Show jumpscare + flash when a target is missed
	_show_jumpscare()
	_shout_random()
	_spawn_target()


func _show_jumpscare() -> void:
	if jumpscare_textures.is_empty():
		return
	# Pick a random jumpscare image
	var jump_tex: Texture2D = jumpscare_textures.pick_random()
	jumpscare_image.texture = jump_tex
	jumpscare_image.visible = true

	# White flash overlay
	flash_overlay.color.a = 0.0
	var flash_tween := create_tween()
	flash_tween.tween_property(flash_overlay, "color:a", 0.8, 0.05)
	flash_tween.tween_property(flash_overlay, "color:a", 0.0, 0.15)

	# Jumpscare stays briefly then disappears
	var jump_tween := create_tween()
	jump_tween.tween_interval(0.35)
	jump_tween.tween_callback(func(): jumpscare_image.visible = false)


func _shout_random() -> void:
	var phrase: String = SHOUT_PHRASES.pick_random()
	shout_label.text = phrase
	shout_label.visible = true
	shout_label.modulate.a = 1.0

	# Shake + fade out the shout label
	var t := create_tween()
	t.tween_property(shout_label, "position:x", shout_label.position.x + randf_range(-30, 30), 0.1)
	t.tween_property(shout_label, "position:x", shout_label.position.x, 0.1)
	t.tween_property(shout_label, "modulate:a", 0.0, 1.0)
	t.tween_callback(func(): shout_label.visible = false)


func _on_time_limit() -> void:
	_end(false)


func _update_progress() -> void:
	progress_label.text = "%d / %d" % [hits, cfg["targets"]]


func _end(won: bool) -> void:
	if finished:
		return
	finished = true
	time_limit.stop()
	for c in container.get_children():
		c.queue_free()
	qte_finished.emit(won)
