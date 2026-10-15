extends Node2D

@export var dialogue: DialogueResource       # drag the .dialogue file here
@export var dialogue_start := "start"
@export_file("*.tscn") var next_scene: String   # leave empty to start the minigame

# timings in seconds
const BLACK_HOLD := 0.8      # black screen before the text
const TEXT_FADE_IN := 1.5
const TEXT_HOLD := 1.5
const TEXT_FADE_OUT := 1.0
const SCENE_FADE_IN := 1.5
const END_FADE_OUT := 1.5

@onready var fade: ColorRect = $FadeLayer/Fade
@onready var fault_label: Label = $FadeLayer/FaultLabel


func _ready() -> void:
	GameHUD.hide_hud()
	fade.show()
	fade.color.a = 1.0
	fault_label.modulate.a = 0.0

	await _intro()
	await _run_dialogue()
	await _outro()


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
	fade.show()
	var t := create_tween()
	t.tween_property(fade, "color:a", 1.0, END_FADE_OUT)
	await t.finished
