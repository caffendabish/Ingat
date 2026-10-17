extends Node2D

@export var dialogue: DialogueResource
@export var dialogue_start := "start"
@export_file("*.tscn") var next_scene: String


func _ready() -> void:
	GameHUD.hide_hud()
	if dialogue != null:
		DialogueManager.show_dialogue_balloon(dialogue, dialogue_start)
		await DialogueManager.dialogue_ended

	if next_scene != "" and ResourceLoader.exists(next_scene):
		get_tree().change_scene_to_file.call_deferred(next_scene)
