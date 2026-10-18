extends Node2D

func _on_ready() -> void:
	GameHUD.show()
	
func _on_kitchen_body_entered(body: Node2D) -> void:
	get_tree().change_scene_to_file("res://Chapter One/Explorations/House/kithen.tscn")


func _on_bedroom_body_entered(body: Node2D) -> void:
	get_tree().change_scene_to_file("res://Chapter One/Explorations/House/livingroom.tscn")
