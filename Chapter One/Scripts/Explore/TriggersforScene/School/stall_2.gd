extends Node2D



func _on_stall_body_entered(body: Node2D) -> void:
	get_tree().change_scene_to_file("res://Chapter One/Explorations/School/gate.tscn")
