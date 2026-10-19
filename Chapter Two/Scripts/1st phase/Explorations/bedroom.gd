extends Node2D

const INTRO_DIALOGUE := preload("res://Chapter Two/Dialogues/Phase1/11 - HOME_Waking Up After Nightmare.dialogue")

static var intro_played := false

@export_range(-40.0, 6.0) var neighbour_db := -10.0   # quieter in the bedroom
@export_range(-40.0, 6.0) var chatter_db := -15.0
@export_range(-40.0, 6.0) var home_music_db := -6.0

func _ready() -> void:
	AudioManager.play_music("home", 2.0, home_music_db)
	# neighbour + chatter carry over from the dream; this just keeps them going at the bedroom level
	AudioManager.play_ambient("neighbour", neighbour_db, 1.0)
	AudioManager.play_layer("after_layer", "chatter2", chatter_db, 1.0)
	if intro_played:
		return
	intro_played = true

	DialogueManager.show_dialogue_balloon(INTRO_DIALOGUE, "start")
	await DialogueManager.dialogue_ended

func _on_area_2d_body_entered(body: Node2D) -> void:
	get_tree().change_scene_to_file("res://Chapter Two/Explorations/Phase1/Pre Flood/LivingRoom.tscn")
