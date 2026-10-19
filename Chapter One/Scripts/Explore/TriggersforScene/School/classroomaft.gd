extends Node2D

@export var music_name := "level1"
@export_range(-40.0, 6.0) var music_db := 0.0
@export_range(-40.0, 6.0) var sfx_db := 0.0
# a bit quieter than the classroom before the activity
@export_range(-40.0, 6.0) var ambient_db := -4.0
@export_range(-40.0, 6.0) var school_bg_db := -22.0

const INTRO_DIALOGUE := preload("res://Chapter One/Dialogues/2.2 - CLASSROOM_After Activity.dialogue")

static var intro_played := false

func _ready() -> void:
	AudioManager.sfx_offset_db = sfx_db
	AudioManager.play_ambient("classroom", ambient_db, 1.0)
	AudioManager.play_music("schoolmusic", 1.0, school_bg_db)
	if intro_played:
		return
	intro_played = true

	DialogueManager.show_dialogue_balloon(INTRO_DIALOGUE, "start")
	await DialogueManager.dialogue_ended

func _on_hallwaya_ft_body_entered(body: Node2D) -> void:
	AudioManager.stop_ambient(1.0)
	get_tree().change_scene_to_file("res://Chapter One/Explorations/School/hallwayaft.tscn")
