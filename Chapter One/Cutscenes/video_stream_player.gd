extends VideoStreamPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$".".play() 
	$".".finished.connect(_on_finished)
	GameHUD.visible = false

func _on_finished() -> void:
	get_tree().change_scene_to_file("res://Chapter One/Explorations/School/playground.tscn") 
