extends Node2D

const INTRO_DIALOGUE := preload("res://Chapter One/Dialogues/SCENE 2.dialogue")

static var intro_played := false

func _ready() -> void:
	if intro_played:
		return
	intro_played = true

	DialogueManager.show_dialogue_balloon(INTRO_DIALOGUE, "start")
	await DialogueManager.dialogue_ended


#hallway 
func _on_hallway_body_entered(body: Node2D) -> void:
	get_tree().change_scene_to_file("res://Chapter One/Explorations/School/hallway.tscn")

#playground
func _on_playground_body_entered(body: Node2D) -> void:
	get_tree().change_scene_to_file("res://Chapter One/Explorations/School/playground.tscn")

func _on_gym_2_body_entered(body: Node2D) -> void:
	get_tree().change_scene_to_file("res://Chapter One/Explorations/School/gym.tscn")
