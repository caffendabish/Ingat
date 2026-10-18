extends Node2D

const INTRO_DIALOGUE := preload("res://Chapter Two/Dialogues/Phase1/11 - HOME_Waking Up After Nightmare.dialogue")

static var intro_played := false

func _ready() -> void:
	if intro_played:
		return
	intro_played = true

	DialogueManager.show_dialogue_balloon(INTRO_DIALOGUE, "start")
	await DialogueManager.dialogue_ended

func _on_area_2d_body_entered(body: Node2D) -> void:
	get_tree().change_scene_to_file("res://Chapter Two/Explorations/Phase1/Pre Flood/LivingRoom.tscn")
