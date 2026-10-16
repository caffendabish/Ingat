extends Node2D

const INTRO_DIALOGUE := preload("res://Chapter One/Dialogues/SCENE 2.dialogue")

static var intro_played := false

@onready var dialogue_overlay: CanvasLayer = %FirstTalk

func _ready() -> void:
	if intro_played:
		return
	intro_played = true

	dialogue_overlay.show()
	DialogueManager.show_dialogue_balloon(INTRO_DIALOGUE, "start")
	await DialogueManager.dialogue_ended
	dialogue_overlay.hide()


func _on_field_body_entered(body: Node2D) -> void:
	get_tree().change_scene_to_file("res://Chapter One/Explorations/School/field.tscn")
