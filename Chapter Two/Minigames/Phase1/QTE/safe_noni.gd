extends Node

@export var dialogue: DialogueResource
@export var dialogue_start := "start"
@export_file("*.tscn") var next_scene: String
@export var delay := 0.5      # short pause before the text appears


func _ready() -> void:
	GameHUD.hide_hud()
	await get_tree().create_timer(delay).timeout

	if dialogue != null:
		DialogueManager.show_dialogue_balloon(dialogue, dialogue_start)
		await DialogueManager.dialogue_ended
	else:
		push_warning("DialogueRunner: no dialogue assigned.")

	_next()


func _next() -> void:
	if next_scene == "" or not ResourceLoader.exists(next_scene):
		push_warning("DialogueRunner: next scene not set or not found.")
		return
	get_tree().change_scene_to_file.call_deferred(next_scene)
