extends Node2D

@export var music_name := "level1"
@export_range(-40.0, 6.0) var music_db := 0.0
@export var ambient_name := ""
@export_range(-40.0, 6.0) var ambient_db := 0.0
@export_range(-40.0, 6.0) var sfx_db := 0.0
# How loud the school track sits under the classroom ambience
@export_range(-40.0, 6.0) var school_bg_db := -18.0
func _ready() -> void:
	AudioManager.sfx_offset_db = sfx_db
	AudioManager.play_ambient("classroom", ambient_db, 1.0)
	AudioManager.play_music("school", 1.0, school_bg_db)

#hallway
func _on_hallway_body_entered(body: Node2D) -> void:
	AudioManager.stop_ambient(1.0)
	AudioManager.play_music("school", 0.5, music_db)
	
	get_tree().change_scene_to_file("res://Chapter One/Explorations/School/hallway.tscn")
