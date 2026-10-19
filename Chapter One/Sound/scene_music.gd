extends Node
# Drop this on a node in any scene that has no script of its own:
# it starts the chosen background music (name from AudioManager.MUSIC_LIBRARY) when the scene loads.
# If that track is already playing it just keeps going and adjusts the volume.

@export var track := "home"
@export_range(-40.0, 6.0) var volume_db := -6.0
@export var fade_time := 2.0


func _ready() -> void:
	AudioManager.play_music(track, fade_time, volume_db)
