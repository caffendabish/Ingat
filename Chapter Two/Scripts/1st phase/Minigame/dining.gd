extends Node2D

const KITCHEN := "res://Chapter Two/Minigames/Phase1/ICROam/kitchen_c.tscn"
const LIVING_ROOM := "res://Chapter Two/Minigames/Phase1/ICROam/living_room_c.tscn"


func _ready() -> void:
	MinigameTimer.ensure_started(SceneFlow.MINIGAME_TIME)

func _on_to_kitchen_body_entered(_body: Node2D) -> void:
	get_tree().change_scene_to_file.call_deferred(KITCHEN)


func _on_sala_body_entered(_body: Node2D) -> void:
	get_tree().change_scene_to_file.call_deferred(LIVING_ROOM)
