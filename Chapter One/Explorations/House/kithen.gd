extends Node2D
@export var music_name := "level1"
@export_range(-40.0, 6.0) var music_db := 0.0
@export var ambient_name := ""
@export_range(-40.0, 6.0) var ambient_db := 0.0
@export_range(-40.0, 6.0) var sfx_db := 0.0
@export_range(-40.0, 6.0) var neighbour_db := 4.0
#hallway

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AudioManager.sfx_offset_db = sfx_db
	AudioManager.play_music("school", 12, ambient_db)
	# neighbour carries over from the dining room (nightly layers stay in the dining room only)
	AudioManager.play_ambient("neighbour", neighbour_db, 1.0)
	# nightly layers carry over from the dining room
	AudioManager.play_layer("nightly_1", "nightly", -10.0, 2.0)
	AudioManager.play_layer("nightly_2", "nightly2", -12.0, 2.0)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_dining_body_entered(body: Node2D) -> void:
	get_tree().change_scene_to_file("res://Chapter One/Explorations/House/dining.tscn")
