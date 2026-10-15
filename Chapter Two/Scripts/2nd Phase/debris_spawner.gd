extends Node2D

signal debris_touched_player(debris: Debris)

@export var debris_scene: PackedScene              # drag debris.tscn here
@export var debris_textures: Array[Texture2D]      # optional: your debris pictures
@export var spawn_rect := Rect2(0, -150, 1920, 50) # just above the screen
@export var kill_rect := Rect2(-300, -400, 2520, 1900)
@export var speed_range := Vector2(250.0, 450.0)   # fall speed
@export var drift_range := Vector2(-120.0, 120.0)  # sideways current
@export var scale_range := Vector2(0.8, 1.4)
@export var interval_start := 1.2   # seconds between debris at the start
@export var interval_end := 0.5     # ...and at the end (it ramps up)

var running := false
var progress := 0.0      # 0 to 1, set by the minigame
var cooldown := 0.0


func start() -> void:
	running = true


func stop() -> void:
	running = false


func _process(delta: float) -> void:
	if not running:
		return
	cooldown -= delta
	if cooldown <= 0.0:
		_spawn()
		cooldown = lerpf(interval_start, interval_end, progress)


func _spawn() -> void:
	if debris_scene == null:
		push_warning("DebrisSpawner: no debris scene assigned.")
		return
	var d := debris_scene.instantiate() as Debris
	d.position = Vector2(
		randf_range(spawn_rect.position.x, spawn_rect.end.x),
		randf_range(spawn_rect.position.y, spawn_rect.end.y)
	)
	d.velocity = Vector2(
		randf_range(drift_range.x, drift_range.y),
		randf_range(speed_range.x, speed_range.y)
	)
	d.spin = randf_range(-2.0, 2.0)
	d.kill_rect = kill_rect
	d.scale = Vector2.ONE * randf_range(scale_range.x, scale_range.y)

	var sprite := d.get_node_or_null("Sprite2D") as Sprite2D
	if sprite and not debris_textures.is_empty():
		sprite.texture = debris_textures.pick_random()

	d.touched_player.connect(func(x): debris_touched_player.emit(x))
	add_child(d)
