extends Node2D

const INTRO_DIALOGUE := preload("res://Chapter One/Dialogues/EmptyStalls.dialogue")

static var intro_played := false

func _ready() -> void:
	GameHUD.show_hud()

func _on_gate_body_entered(body: Node2D) -> void:
	get_tree().change_scene_to_file("res://Chapter One/Explorations/School/gate.tscn")
