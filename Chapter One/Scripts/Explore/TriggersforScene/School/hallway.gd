extends Node2D


func _ready() -> void:
	GameHUD.show_hud()


func _on_classroom_body_entered(body: Node2D) -> void:
	get_tree().change_scene_to_file("res://Chapter One/Explorations/School/classroom.tscn")

func _on_field_body_entered(body: Node2D) -> void:
	get_tree().change_scene_to_file("res://Chapter One/Explorations/School/field.tscn")
