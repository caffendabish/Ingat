extends Node2D

@export var dialogue: DialogueResource
@export var dialogue_start := "start"
@export_file("*.tscn") var next_scene: String
@export_range(-40.0, 6.0) var thunder3_db := -4.0   # thunder3 comes in right away here and stays for every scene after
@export var thunder3_fade_in := 0.5


func _ready() -> void:
	GameHUD.hide_hud()
	AudioManager.play_layer("storm_thunder3", "thunder3", thunder3_db, thunder3_fade_in)
	if dialogue != null:
		DialogueManager.show_dialogue_balloon(dialogue, dialogue_start)
		await DialogueManager.dialogue_ended

	if next_scene != "" and ResourceLoader.exists(next_scene):
		get_tree().change_scene_to_file.call_deferred(next_scene)
