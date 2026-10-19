extends Node2D

@export var dialogue: DialogueResource       # drag the .dialogue file here
@export var dialogue_start := "start"
@export_file("*.tscn") var next_scene: String   # leave empty to start the minigame
# ambience for this cutscene (name from AudioManager.AMBIENT_LIBRARY). Empty = leave audio alone.
# Playing it replaces whatever ambience was running (e.g. the classroom).
@export var ambient_sound := ""
@export_range(-40.0, 6.0) var ambient_sound_db := 0.0
# fade out whatever music is still playing (e.g. the school track) when this cutscene starts
@export var stop_music_on_start := false
# optional extra sounds layered under the main ambience; they fade out when the cutscene ends
@export var layer_1_sound := ""
@export_range(-40.0, 6.0) var layer_1_db := -10.0
@export var layer_2_sound := ""
@export_range(-40.0, 6.0) var layer_2_db := -12.0
# ambience to bring back when the cutscene ends (replaces the main ambience). Empty = leave it.
@export var after_sound := ""
@export_range(-40.0, 6.0) var after_sound_db := 0.0
# optional extra layer started together with after_sound when the cutscene ends (e.g. chatter)
@export var after_layer_sound := ""
@export_range(-40.0, 6.0) var after_layer_db := -10.0
# fade this cutscene's own ambience out when it ends, instead of leaving it for the next scene
@export var stop_ambient_on_end := false

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
	if stop_music_on_start:
		AudioManager.stop_music(0.5)
	if layer_1_sound != "" or layer_2_sound != "":
		# the house's nightly layers stop as soon as the dream starts
		AudioManager.stop_all_layers(0.5)
	if ambient_sound != "":
		# replaces the neighbour sound
		AudioManager.play_ambient(ambient_sound, ambient_sound_db, 2.0)
	if layer_1_sound != "":
		AudioManager.play_layer("cutscene_1", layer_1_sound, layer_1_db, 2.0)
	if layer_2_sound != "":
		AudioManager.play_layer("cutscene_2", layer_2_sound, layer_2_db, 2.0)
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
	DialogueManager.show_dialogue_balloon(dialogue, dialogue_start)
	await DialogueManager.dialogue_ended


# fade back to black when the dialogue ends
func _outro() -> void:
	if layer_1_sound != "" or layer_2_sound != "":
		AudioManager.stop_all_layers(END_FADE_OUT)
	if after_sound != "":
		AudioManager.play_ambient(after_sound, after_sound_db, END_FADE_OUT)
	elif stop_ambient_on_end:
		AudioManager.stop_ambient(END_FADE_OUT)
	if after_layer_sound != "":
		AudioManager.play_layer("after_layer", after_layer_sound, after_layer_db, END_FADE_OUT)
	fade.show()
	var t := create_tween()
	t.tween_property(fade, "color:a", 1.0, END_FADE_OUT)
	await t.finished


func _next() -> void:
	if next_scene != "" and ResourceLoader.exists(next_scene):
		get_tree().change_scene_to_file.call_deferred(next_scene)
	else:
		SceneFlow.start_minigame()   # this cutscene leads into the minigame
