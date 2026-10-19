extends Node2D

@export var dialogue: DialogueResource
@export var dialogue_start := "start"
@export_file("*.tscn") var next_scene: String   # EMPTY = start the Phase 1 minigame
@export var show_fault_text := true             # turn off for BeforeStorm
# neighbour sound carries over from the house; quieter here than in the exploration scenes
@export_range(-40.0, 6.0) var neighbour_db := -4.0
@export_range(-40.0, 6.0) var thunder_start_db := -20.0   # quietish when the thunder triggers
@export_range(-40.0, 6.0) var thunder_loud_db := -4.0     # where it swells to
@export var thunder_swell_after_lines := 2                # dialogue lines after the trigger before it gets louder
@export var fade_out_time := 4.0                          # seconds for neighbour/chatter to fade away

var _thunder_played := false
var _lines_since_thunder := 0
var _thunder_layers := ["thunder", "thunder1", "thunder2"]

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
	# neighbour keeps playing (quieter); switches to thunder when Pili says "just thunder"
	AudioManager.play_ambient("neighbour", neighbour_db, 1.0)
	DialogueManager.got_dialogue.connect(_on_got_dialogue)
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


# when Pili says "It's just thunder, dear.": every other sound stops, then thunder, thunder1
# and thunder2 start quiet and swell louder after a couple of lines
func _on_got_dialogue(line) -> void:
	if _thunder_played:
		_lines_since_thunder += 1
		if _lines_since_thunder == thunder_swell_after_lines:
			for sound in _thunder_layers:
				AudioManager.play_layer("storm_" + sound, sound, thunder_loud_db, 3.0)
		return
	if line.text.contains("just thunder"):
		_thunder_played = true
		# neighbour + chatter (and any music) fade away gradually instead of cutting off
		AudioManager.stop_ambient(fade_out_time)
		AudioManager.stop_music(fade_out_time)
		AudioManager.stop_all_layers(fade_out_time)
		for sound in _thunder_layers:
			AudioManager.play_layer("storm_" + sound, sound, thunder_start_db, 1.0)


# fade back to black when the dialogue ends
func _outro() -> void:
	# the thunder layers are NOT stopped here; they carry on through the minigame and the argument scene
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
