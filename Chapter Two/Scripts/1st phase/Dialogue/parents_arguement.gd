extends Node2D

@export var dialogue: DialogueResource       # drag the .dialogue file here
@export var dialogue_start := "start"
@export_file("*.tscn") var next_scene: String   # leave empty to start the minigame
@export_range(-40.0, 6.0) var cries_db := -22.0   # quiet background crying
@export var thunder_lower_db := 0.0               # 0 = leave thunder alone; negative = lower it during this dialogue
@export var thunder_lower_fade := 3.0
# turn on for the ending scenes: fades out the flood screams as soon as the scene starts
@export var stop_screams_on_start := false
@export var screams_fade_out := 1.5
# ending scenes: background music to start (name from AudioManager.MUSIC_LIBRARY); empty = leave music alone
@export var start_music := ""
@export_range(-40.0, 6.0) var start_music_db := -6.0
@export var start_music_fade := 2.0

# timings in seconds
const BLACK_HOLD := 0.8      # black screen before the text
const TEXT_FADE_IN := 1.5
const TEXT_HOLD := 1.5
const TEXT_FADE_OUT := 1.0
const SCENE_FADE_IN := 2.0
const END_FADE_OUT := 1.5

@onready var fade: ColorRect = $FadeLayer/Fade
@onready var fault_label: Label = $FadeLayer/FaultLabel


func _ready() -> void:
	GameHUD.hide_hud()
	if stop_screams_on_start:
		AudioManager.stop_layer("screams", screams_fade_out)
	if start_music != "":
		AudioManager.play_music(start_music, start_music_fade, start_music_db)
	fade.show()
	fade.color.a = 1.0
	fault_label.modulate.a = 0.0

	await _intro()
	await _run_dialogue()
	await _outro()
	_next()


# black -> text fades in -> text fades out -> scene fades in
func _intro() -> void:
	var t := create_tween()
	t.tween_interval(BLACK_HOLD)
	t.tween_property(fault_label, "modulate:a", 1.0, TEXT_FADE_IN)
	t.tween_interval(TEXT_HOLD)
	t.tween_property(fault_label, "modulate:a", 0.0, TEXT_FADE_OUT)
	t.tween_property(fade, "color:a", 0.0, SCENE_FADE_IN)
	await t.finished
	fade.hide()   # so it never blocks the dialogue box


func _run_dialogue() -> void:
	if dialogue == null:
		push_warning("ParentsArguement: no dialogue file assigned in the Inspector.")
		return
	# crying in the background while Pili and Ernesto argue (kept quiet)
	AudioManager.play_layer("cries", "cries", cries_db, 2.0)
	if thunder_lower_db != 0.0:
		AudioManager.shift_layers_db("storm_thunder", thunder_lower_db, thunder_lower_fade)
	DialogueManager.show_dialogue_balloon(dialogue, dialogue_start)
	await DialogueManager.dialogue_ended


# fade back to black when the dialogue ends
func _outro() -> void:
	AudioManager.stop_layer("cries", END_FADE_OUT)
	# only the cries stop here. The thunder layers (storm_thunder, storm_thunder1, storm_thunder2)
	# keep running through the attic/roof choice, the attic and roof scenes, the dodge minigame
	# and every scene after the argument.
	fade.show()
	var t := create_tween()
	t.tween_property(fade, "color:a", 1.0, END_FADE_OUT)
	await t.finished


func _next() -> void:
	if next_scene != "" and ResourceLoader.exists(next_scene):
		get_tree().change_scene_to_file.call_deferred(next_scene)
	else:
		SceneFlow.start_minigame()   # this cutscene leads into the minigame
