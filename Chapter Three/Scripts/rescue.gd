extends Node2D

@export var dialogue: DialogueResource       # drag the .dialogue file here
@export var dialogue_start := "start"
@export_file("*.tscn") var next_scene: String   # leave empty to start the minigame

# Phase 3 QTE settings
@export var use_qte := true                  # tick this only on the Phase 3 scene
@export_file("*.tscn") var safe_ending_scene: String
@export_file("*.tscn") var separated_ending_scene: String

const QTE_SCENE := preload("res://Chapter Three/Minigames/PhaseThreeQTE.tscn")

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
	fade.show()
	fade.color.a = 1.0
	fault_label.modulate.a = 0.0

	await _intro()
	await _run_dialogue()

	if use_qte:
		var won: bool = await _run_qte()
		await _outro()
		_go_to_ending(won)
	else:
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


# Runs the QTE and returns true if the player won
func _run_qte() -> bool:
	# Put the QTE on its own CanvasLayer so its Full Rect anchors fill the screen
	var layer := CanvasLayer.new()
	layer.layer = 10
	add_child(layer)

	var qte = QTE_SCENE.instantiate()
	layer.add_child(qte)
	qte.start()   # no argument: difficulty comes from the Inventory autoload

	var won: bool = await qte.qte_finished
	layer.queue_free()
	return won


# fade back to black
func _outro() -> void:
	fade.show()
	var t := create_tween()
	t.tween_property(fade, "color:a", 1.0, END_FADE_OUT)
	await t.finished


func _go_to_ending(won: bool) -> void:
	var target := safe_ending_scene if won else separated_ending_scene
	if target != "" and ResourceLoader.exists(target):
		get_tree().change_scene_to_file.call_deferred(target)
	else:
		push_warning("Ending scene not set or not found: " + target)


func _next() -> void:
	if next_scene != "" and ResourceLoader.exists(next_scene):
		get_tree().change_scene_to_file.call_deferred(next_scene)
	else:
		SceneFlow.start_minigame()   # this cutscene leads into the minigame
