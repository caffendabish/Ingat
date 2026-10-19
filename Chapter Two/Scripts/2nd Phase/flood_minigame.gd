extends Node2D

@export var intro_dialogue: DialogueResource             # plays before the minigame starts
@export var intro_start := "start"

@export_file("*.tscn") var safe_scene: String            # 0 hits
@export_file("*.tscn") var special_qte_scene: String     # 1 to 4 hits
@export_file("*.tscn") var washed_away_scene: String     # 5+ hits (leads to the ending)

@export var duration := 40.0           # seconds to survive
@export var fail_hits := 5             # this many hits = full failure
@export var insanity_per_hit := 6
@export var hit_cooldown := 0.6        # grace period so a cluster isn't 3 hits
@export var water_rise := 180.0        # pixels the Water rectangle rises (visual only)
@export var debug_keys := true         # H = fake a hit. Turn off when done.
@export_range(-40.0, 6.0) var screams_db := -8.0   # screams start with the dodge and carry on until the ending scene fades them out
@export var screams_fade_in := 2.0

const END_DELAY := 1.2   # pause so the player sees the last hit

@onready var player = $Player
@onready var spawner = $DebrisSpawner
@onready var survive_bar := get_node_or_null("UI/SurviveBar") as ProgressBar
@onready var water := get_node_or_null("Water") as Control

var started := false         # becomes true when the intro dialogue ends
var hits := 0
var elapsed := 0.0
var cooldown_left := 0.0
var finished := false
var resolving := false


func _ready() -> void:
	GameHUD.show_meter_only()                # only the meter shows
	GameState.insanity_revealed = true
	GameState.set_flag(&"flood_hits", 0)

	if survive_bar:
		survive_bar.max_value = duration
		survive_bar.show_percentage = false

	spawner.debris_touched_player.connect(_on_debris_touched)
	player.enabled = false                   # frozen during the dialogue

	await _play_intro()
	_start_game()


func _play_intro() -> void:
	if intro_dialogue == null:
		push_warning("FloodMinigame: no intro dialogue assigned, starting right away.")
		return
	DialogueManager.show_dialogue_balloon(intro_dialogue, intro_start)
	await DialogueManager.dialogue_ended


func _start_game() -> void:
	started = true
	player.enabled = true
	spawner.start()
	# thunder3 now starts earlier, in the attic/roof scenes (see attic.gd / window.gd)
	AudioManager.play_layer("screams", "screams", screams_db, screams_fade_in)
	if water:
		create_tween().tween_property(water, "position:y", water.position.y - water_rise, duration)


func _process(delta: float) -> void:
	if finished or not started:
		return
	elapsed += delta
	cooldown_left = maxf(cooldown_left - delta, 0.0)
	spawner.progress = clampf(elapsed / duration, 0.0, 1.0)
	if survive_bar:
		survive_bar.value = elapsed
	if elapsed >= duration:
		_finish()


func _unhandled_input(event: InputEvent) -> void:
	if debug_keys and event is InputEventKey and event.pressed and not event.echo \
			and event.keycode == KEY_H:
		_register_hit()


func _on_debris_touched(debris: Debris) -> void:
	if finished or not started or cooldown_left > 0.0:
		return                     # grace period: debris passes through
	debris.queue_free()
	_register_hit()


func _register_hit() -> void:
	if finished or not started:
		return
	hits += 1
	cooldown_left = hit_cooldown
	GameState.set_flag(&"flood_hits", hits)
	GameState.add_insanity(insanity_per_hit, "flood debris hit %d" % hits)

	# a full meter sends the player to the ending by itself, so just stop here
	if SceneFlow.ending_started:
		finished = true
		resolving = true
		spawner.stop()
		return

	_hit_feedback()
	if hits >= fail_hits:
		_finish()


func _hit_feedback() -> void:
	player.modulate = Color(1.0, 0.3, 0.3)
	create_tween().tween_property(player, "modulate", Color.WHITE, 0.4)


func _finish() -> void:
	if resolving:
		return
	resolving = true
	finished = true
	spawner.stop()
	player.enabled = false
	GameState.set_flag(&"flood_hits", hits)

	await get_tree().create_timer(END_DELAY).timeout

	if SceneFlow.ending_started:
		return

	if hits >= fail_hits:
		# FULL FAILURE: Ollie is washed away, then the isolated ending
		GameState.set_flag(&"flood_result", "full_failure")
		GameHUD.hide_hud()
		if washed_away_scene != "":
			_change(washed_away_scene)
		else:
			SceneFlow.go_isolated_ending()
	elif hits == 0:
		# SUCCESS: starting insanity LOW
		GameState.set_flag(&"flood_result", "success")
		GameState.set_flag(&"phase3_start", "low")
		_change(safe_scene)
	else:
		# PARTIAL: the "who to save" QTE
		GameState.set_flag(&"flood_result", "partial")
		_change(special_qte_scene)


func _change(path: String) -> void:
	if path == "" or not ResourceLoader.exists(path):
		push_error("FloodMinigame: outcome scene not set or not found -> '%s'" % path)
		return
	get_tree().change_scene_to_file.call_deferred(path)
