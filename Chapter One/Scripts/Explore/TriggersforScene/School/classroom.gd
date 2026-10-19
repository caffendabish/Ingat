extends Node2D


func _ready() -> void:
	GameHUD.show_hud()

#hallway
func _on_hallway_body_entered(body: Node2D) -> void:
	get_tree().change_scene_to_file("res://Chapter One/Explorations/School/hallway.tscn")
