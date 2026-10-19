extends Node2D

@export var dialogue: DialogueResource           # your .dialogue file (already assigned)
@export var dialogue_start := "start"
@export_file("*.tscn") var next_scene: String    # the scene that comes after

# FADE_IN + HOLD + FADE_OUT = 10 seconds before the dialogue plays
const BLACK_HOLD := 1.0   # black screen before the meter appears
const FADE_IN := 1.5
const HOLD := 7.0
const FADE_OUT := 1.5

@onready var bar: TextureRect = $InsanityBar


func _ready() -> void:
	GameHUD.hide_hud()                    # no second meter, no Bag or notebook
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bar.modulate.a = 0.0                  # invisible until it fades in
	_show_current_frame()

	await get_tree().create_timer(BLACK_HOLD).timeout
	await _fade_meter()

	GameState.insanity_revealed = true    # later scenes will show the HUD meter
	await _run_dialogue()
	_next()


# Picks the meter image that matches the player's real insanity
func _show_current_frame() -> void:
	var frames: Array = GameHUD.meter_frames
	if frames.is_empty():
		return
	var i := roundi(float(GameState.insanity) / GameState.MAX_INSANITY * (frames.size() - 1))
	bar.texture = frames[clampi(i, 0, frames.size() - 1)]


# fade in -> hold -> fade out
func _fade_meter() -> void:
	var t := create_tween()
	t.tween_property(bar, "modulate:a", 1.0, FADE_IN)
	t.tween_interval(HOLD)
	t.tween_property(bar, "modulate:a", 0.0, FADE_OUT)
	await t.finished


func _run_dialogue() -> void:
	if dialogue == null:
		push_warning("InsanityIntro: no dialogue file assigned.")
		return
	DialogueManager.show_dialogue_balloon(dialogue, dialogue_start)
	await DialogueManager.dialogue_ended


func _next() -> void:
	GameHUD.show_hud()   # Bag, notebook and the HUD meter come back
	if next_scene == "" or not ResourceLoader.exists(next_scene):
		push_warning("InsanityIntro: next scene not set or not found.")
		return
	get_tree().change_scene_to_file.call_deferred(next_scene)
