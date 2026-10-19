extends Node

# ---------- CHANGE THESE PATHS ----------
const FIRST_ROOM := "res://Chapter Two/Minigames/Phase1/ICROam/dining.tscn"
const AFTER_MINIGAME := "res://Chapter Two/Dialogues/Phase1/ParentsArguement.tscn"
const ISOLATED_ENDING := "res://Chapter Three/Dialogues/IsolatedEnding.tscn"

const MINIGAME_TIME := 60.0    # Phase 1 timer, 1 minute
const QUEST := &"ch2_gather"
const DEBUG_KEYS := true       # F2 = 10s timer, F3 = start Phase 1, F4 = wipe everything

var ending_started := false


func _ready() -> void:
	MinigameTimer.time_up.connect(_on_time_up)
	Inventory.item_added.connect(_on_item_added)
	GameState.isolated_ending_triggered.connect(go_isolated_ending)


# Call this at the end of the Phase 1 intro cutscene.
# It does NOT clear the bag, insanity, or flags.
func start_minigame() -> void:
	ending_started = false

	QuestLog.add_quest(
		QUEST,
		"Gather What You Need",
		"Time is short. Take what you can carry.",
		["Explore the house", "Collect your items", "Decide: Attic or Window"]
	)

	GameHUD.show_hud()
	MinigameTimer.reset()        # timer only
	MinigameTimer.start(MINIGAME_TIME)   # starts clock + shows spooky gather text
	_go(FIRST_ROOM)


func _on_item_added(_item: ItemData) -> void:
	QuestLog.complete_objective(QUEST, 0)   # first pickup counts as exploring


# Phase 1 timer ends -> hide the HUD -> cutscene
func _on_time_up() -> void:
	if ending_started:
		return
	QuestLog.complete_objective(QUEST, 1)
	GameHUD.hide_hud()
	_go(AFTER_MINIGAME)


# Meter full (any phase) or 5 flood hits. Safe to call many times.
func go_isolated_ending() -> void:
	if ending_started:
		return
	ending_started = true
	MinigameTimer.stop()
	GameHUD.hide_hud()
	_go(ISOLATED_ENDING)


func _go(path: String) -> void:
	if path == "" or not ResourceLoader.exists(path):
		push_error("SceneFlow: scene not found -> '%s'" % path)
		return
	get_tree().change_scene_to_file.call_deferred(path)


func _input(event: InputEvent) -> void:
	if not DEBUG_KEYS:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F2:
			MinigameTimer.start(10.0)
		elif event.keycode == KEY_F3:
			start_minigame()
		elif event.keycode == KEY_F4:
			GameState.new_game()
			print("DEBUG: everything reset")
