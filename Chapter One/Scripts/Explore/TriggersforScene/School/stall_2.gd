extends Node2D

const INTRO_DIALOGUE := preload("res://Chapter One/Dialogues/EmptyStalls.dialogue")

static var intro_played := false

func _ready() -> void:
	if intro_played:
		return
	intro_played = true

	DialogueManager.show_dialogue_balloon(INTRO_DIALOGUE, "start")
	await DialogueManager.dialogue_ended
	GameHUD.show_hud()

func _on_stall_body_entered(body: Node2D) -> void:
	get_tree().change_scene_to_file("res://Chapter One/Explorations/School/gate.tscn")
