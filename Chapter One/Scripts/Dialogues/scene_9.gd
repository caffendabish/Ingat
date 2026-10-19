extends Node2D

@export var dialogue: DialogueResource       # drag the .dialogue file here
@export var dialogue_start := "start"
@export_file("*.tscn") var next_scene: String   # leave empty to start the minigame
# neighbour carries over from cutscene 8; the TV layers are added on top
@export_range(-40.0, 6.0) var neighbour_db := 4.0
@export_range(-40.0, 6.0) var tv_static_db := -6.0
@export_range(-40.0, 6.0) var tv_mumble_db := -14.0   # quieter than the static

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
	AudioManager.play_ambient("neighbour", neighbour_db, 1.0)
	AudioManager.play_layer("tv_static", "tv_static", tv_static_db, 2.0)
	AudioManager.play_layer("tv_mumble", "mumble", tv_mumble_db, 2.0, "SFX")
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
	# neighbour keeps playing into the dining room; only the TV layers stop
	AudioManager.stop_all_layers(END_FADE_OUT)
	fade.show()
	var t := create_tween()
	t.tween_property(fade, "color:a", 1.0, END_FADE_OUT)
	await t.finished


func _next() -> void:
	if next_scene != "" and ResourceLoader.exists(next_scene):
		get_tree().change_scene_to_file.call_deferred(next_scene)
	else:
		SceneFlow.start_minigame()   # this cutscene leads into the minigame
