extends Node2D

@export_range(-40.0, 6.0) var neighbour_db := 4.0


func _ready() -> void:
	AudioManager.play_ambient("neighbour", neighbour_db, 1.0)
	# nightly layers carry over from the dining room / kitchen
	AudioManager.play_layer("nightly_1", "nightly", -10.0, 2.0)
	AudioManager.play_layer("nightly_2", "nightly2", -12.0, 2.0)


func _on_dining_body_entered(body: Node2D) -> void:
	get_tree().change_scene_to_file("res://Chapter One/Explorations/House/dining.tscn")


func _on_bedroom_body_entered(body: Node2D) -> void:
	get_tree().change_scene_to_file("res://Chapter One/Explorations/House/bedroom.tscn")
