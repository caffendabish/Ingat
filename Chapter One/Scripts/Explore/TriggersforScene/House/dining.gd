extends Node2D

@export_range(-40.0, 6.0) var neighbour_db := 0.0   # reduced in the dining room (+4 elsewhere)
@export_range(-40.0, 6.0) var home_music_db := -6.0
@export_range(-40.0, 6.0) var nightly_db := -10.0
@export_range(-40.0, 6.0) var nightly2_db := -12.0


func _ready() -> void:
	AudioManager.play_music("home", 2.0, home_music_db)
	# carries over from cutscene 9; if it's already playing this just keeps it going
	AudioManager.play_ambient("neighbour", neighbour_db, 1.0)
	# nightly layers on top; they keep playing into the kitchen and living room
	AudioManager.play_layer("nightly_1", "nightly", nightly_db, 2.0)
	AudioManager.play_layer("nightly_2", "nightly2", nightly2_db, 2.0)


func _on_kitchen_body_entered(body: Node2D) -> void:
	get_tree().change_scene_to_file("res://Chapter One/Explorations/House/kithen.tscn")


func _on_bedroom_body_entered(body: Node2D) -> void:
	get_tree().change_scene_to_file("res://Chapter One/Explorations/House/livingroom.tscn")
