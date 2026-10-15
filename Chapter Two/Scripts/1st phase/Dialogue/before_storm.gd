extends Node2D

@export var dialogue: DialogueResource
@export var dialogue_start := "start"
@export_file("*.tscn") var next_scene: String   # EMPTY = start the Phase 1 minigame
@export var show_fault_text := true             # turn off for BeforeStorm

const BLACK_HOLD := 0.8
const TEXT_FADE_IN := 1.5
const TEXT_HOLD := 1.5
const TEXT_FADE_OUT := 1.0
const SCENE_FADE_IN := 2.0
const END_FADE_OUT := 1.5

@onready var fade: ColorRect = $FadeLayer/Fade
@onready var fault_label: Label = $FadeLayer/FaultLabel


func _ready() -> void:
	GameHUD.hide_hud()
	fade.show()
	fade.color.a = 1.0
	fault_label.visible = show_fault_text
	fault_label.modulate.a = 0.0

	await _intro()
	await _run_dialogue()
	print("[Cutscene] dialogue finished")          # debug, remove later
	await _outro()
	_next()


# black -> (text fades in and out) -> scene fades in
func _intro() -> void:
	var t := create_tween()
	t.tween_interval(BLACK_HOLD)
	if show_fault_text:
		t.tween_property(fault_label, "modulate:a", 1.0, TEXT_FADE_IN)
		t.tween_interval(TEXT_HOLD)
		t.tween_property(fault_label, "modulate:a", 0.0, TEXT_FADE_OUT)
	t.tween_property(fade, "color:a", 0.0, SCENE_FADE_IN)
	await t.finished
	fade.hide()


func _run_dialogue() -> void:
	if dialogue == null:
		push_warning("Cutscene: no dialogue assigned.")
		return
	DialogueManager.show_dialogue_balloon(dialogue, dialogue_start)
	await DialogueManager.dialogue_ended


# fade back to black when the dialogue ends
func _outro() -> void:
	fade.show()
	var t := create_tween()
	t.tween_property(fade, "color:a", 1.0, END_FADE_OUT)
	await t.finished


func _next() -> void:
	if next_scene != "" and ResourceLoader.exists(next_scene):
		print("[Cutscene] going to: ", next_scene)  # debug, remove later
		get_tree().change_scene_to_file.call_deferred(next_scene)
	else:
		print("[Cutscene] starting the minigame")   # debug, remove later
		SceneFlow.start_minigame()   # starts the timer, shows the HUD, adds the quest
