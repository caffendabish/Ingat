extends Node2D

func _on_dining_body_entered(body: Node2D) -> void:
	get_tree().change_scene_to_file("res://Chapter Two/Minigames/Phase1/ICROam/dining.tscn")
