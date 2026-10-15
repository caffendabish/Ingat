extends Node2D

#hallway
func _on_hallway_body_entered(body: Node2D) -> void:
	get_tree().change_scene_to_file("res://Chapter One/Explorations/School/hallway.tscn")
