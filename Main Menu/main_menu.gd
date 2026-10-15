extends Node2D

func _ready() -> void:
	GameHUD.visible = false


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://Chapter One/Cutscenes/Cutscene.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()
