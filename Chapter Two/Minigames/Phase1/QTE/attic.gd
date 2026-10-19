extends Node2D

@export var dialogue: DialogueResource
@export var dialogue_start := "start"
@export_file("*.tscn") var next_scene: String

@onready var thunder1_player: AudioStreamPlayer = $Thunder1Player
@onready var thunder2_player: AudioStreamPlayer = $Thunder2Player
@onready var thunder3_player: AudioStreamPlayer = $Thunder3Player


func _ready() -> void:
	GameHUD.hide_hud()
	if dialogue != null:
		DialogueManager.show_dialogue_balloon(dialogue, dialogue_start)
		await DialogueManager.dialogue_ended

	# Play thunder sequence after attic choice
	thunder1_player.play()
	await get_tree().create_timer(1.5).finished
	thunder2_player.play()
	await get_tree().create_timer(1.5).finished
	thunder3_player.play()

	if next_scene != "" and ResourceLoader.exists(next_scene):
		get_tree().change_scene_to_file.call_deferred(next_scene)
