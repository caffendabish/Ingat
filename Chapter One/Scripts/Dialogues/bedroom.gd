extends Node2D

const INTRO_DIALOGUE := preload("res://Chapter One/Dialogues/6 - BEDROOM_Sleepy Time.dialogue")

static var intro_played := false

@export_range(-40.0, 6.0) var neighbour_db := -10.0   # quieter in the bedroom
@export_range(-40.0, 6.0) var home_music_db := -6.0

func _ready() -> void:
	AudioManager.play_music("home", 2.0, home_music_db)
	AudioManager.play_ambient("neighbour", neighbour_db, 1.0)
	AudioManager.play_layer("nightly_1", "nightly", -10.0, 2.0)
	AudioManager.play_layer("nightly_2", "nightly2", -12.0, 2.0)
	if intro_played:
		return
	intro_played = true

	DialogueManager.show_dialogue_balloon(INTRO_DIALOGUE, "start")
	await DialogueManager.dialogue_ended


func _on_area_2d_body_entered(body: Node2D) -> void:
	# everything from the house stops as the dream starts
	AudioManager.stop_ambient(0.5)
	AudioManager.stop_all_layers(0.5)
	AudioManager.stop_music(0.5)
	get_tree().change_scene_to_file("res://Chapter One/Dialogues/Scenes/Dream.tscn")
