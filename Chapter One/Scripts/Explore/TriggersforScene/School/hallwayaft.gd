extends Node2D

@export var music_name := "level1"
@export_range(-40.0, 6.0) var music_db := 0.0
@export var ambient_name := ""
@export_range(-40.0, 6.0) var ambient_db := 0.0
@export_range(-40.0, 6.0) var sfx_db := 0.0
#hallway
func _ready():
	AudioManager.sfx_offset_db = sfx_db
	AudioManager.play_music("schoolmusic", 12, ambient_db)

func _on_field_body_entered(body: Node2D) -> void:
	get_tree().change_scene_to_file("res://Chapter One/Explorations/School/fieldaft.tscn")
