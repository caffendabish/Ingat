extends Node2D

@export var dialogue: DialogueResource       # drag the .dialogue file here
@export var dialogue_start := "start"
@export_file("*.tscn") var next_scene: String   # leave empty to start the minigame

# timings in seconds
const SCENE_FADE_IN := 2.0      # fade from black to transparent before dialogue
const END_FADE_OUT := 3.0       # fade to black after dialogue ends
const LABEL_HOLD := 2.0         # how long the label stays visible on black before next scene

# Somber fade color
const SOMBER_DARK := Color(0.08, 0.06, 0.10, 1.0)   # near-black with a subtle purple-blue tint
const SOMBER_TEXT := Color(0.68, 0.62, 0.58, 1.0)   # muted desaturated text

@onready var fade: ColorRect = $FadeLayer/Fade
@onready var fault_label: Label = $FadeLayer/FaultLabel


func _ready() -> void:
	GameHUD.hide_hud()
	fade.show()
	fade.color = SOMBER_DARK      # start on black
	fault_label.visible = false   # label hidden until after fade-out

	await _fade_in()              # fade from black to transparent
	await _run_dialogue()         # dialogue plays
	await _fade_out()             # fade to black
	await _show_label()           # label appears on black
	_next()


# Fade from black to transparent before the dialogue
func _fade_in() -> void:
	var t := create_tween()
	t.tween_property(fade, "color:a", 0.0, SCENE_FADE_IN)
	await t.finished


# Dialogue plays
func _run_dialogue() -> void:
	if dialogue == null:
		push_warning("EndingDialogue: no dialogue file assigned in the Inspector.")
		return
	DialogueManager.show_dialogue_balloon(dialogue, dialogue_start)
	await DialogueManager.dialogue_ended


# Fade from transparent to black after the dialogue
func _fade_out() -> void:
	var t := create_tween()
	t.tween_property(fade, "color:a", 1.0, END_FADE_OUT)
	await t.finished


# Label fades in on the black screen after the fade completes
func _show_label() -> void:
	fault_label.visible = true
	fault_label.modulate = SOMBER_TEXT
	fault_label.modulate.a = 0.0
	var t := create_tween()
	t.tween_property(fault_label, "modulate:a", 1.0, 1.0)
	t.tween_interval(LABEL_HOLD)
	await t.finished


func _next() -> void:
	if next_scene != "" and ResourceLoader.exists(next_scene):
		get_tree().change_scene_to_file.call_deferred(next_scene)
	else:
		SceneFlow.start_minigame()   # this cutscene leads into the minigame
