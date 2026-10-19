extends Node2D
@export var music_name := "level1"
@export_range(-40.0, 6.0) var music_db := 0.0
@export var ambient_name := ""
@export_range(-40.0, 6.0) var ambient_db := 0.0
@export_range(-40.0, 6.0) var sfx_db := 0.0
func _ready() -> void:
	AudioManager.sfx_offset_db = sfx_db
	AudioManager.play_music("schoolmusic", 2.0, music_db)

#hallway
func _on_hallway_body_entered(body: Node2D) -> void:
	AudioManager.sfx_offset_db = sfx_db
	AudioManager.play_music("schoolmusic", 12, ambient_db)
	get_tree().change_scene_to_file("res://Chapter One/Explorations/School/hallway.tscn")

#playground
func _on_playground_body_entered(body: Node2D) -> void:
	get_tree().change_scene_to_file("res://Chapter One/Explorations/School/playground.tscn")

func _on_gym_2_body_entered(body: Node2D) -> void:
	get_tree().change_scene_to_file("res://Chapter One/Explorations/School/gym.tscn")
