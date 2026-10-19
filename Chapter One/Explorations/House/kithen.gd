extends Node2D


func _ready() -> void:
	GameHUD.show_hud()


func _on_dining_body_entered(body: Node2D) -> void:
	get_tree().change_scene_to_file("res://Chapter One/Explorations/House/dining.tscn")
