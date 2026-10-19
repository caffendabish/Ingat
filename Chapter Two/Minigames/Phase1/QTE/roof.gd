class_name ItemBranch
extends Node

@export var required_item: ItemData              # rope.tres or the first aid kit
@export var dialogue: DialogueResource           # optional: plays first
@export var dialogue_start := "start"
@export var auto_start := true                   # off = call resolve() yourself

@export_file("*.tscn") var scene_if_has: String
@export_file("*.tscn") var scene_if_missing: String
@export var flag_if_has: StringName              # e.g. noni_safe
@export var flag_if_missing: StringName          # e.g. noni_injured

@onready var thunder1_player: AudioStreamPlayer = $Thunder1Player
@onready var thunder2_player: AudioStreamPlayer = $Thunder2Player
@onready var thunder3_player: AudioStreamPlayer = $Thunder3Player

var resolved := false


func _ready() -> void:
	GameHUD.hide_hud()
	if not auto_start:
		return
	if dialogue != null:
		DialogueManager.show_dialogue_balloon(dialogue, dialogue_start)
		await DialogueManager.dialogue_ended

	# Play thunder sequence after roof choice
	thunder1_player.play()
	await get_tree().create_timer(1.5).finished
	thunder2_player.play()
	await get_tree().create_timer(1.5).finished
	thunder3_player.play()

	resolve()


# The branch itself. Safe to call more than once.
func resolve() -> void:
	if resolved:
		return
	resolved = true

	var has_it := required_item == null or Inventory.has_item(required_item.id)

	if has_it:
		GameState.set_flag(&"phase2_start", "low")
		if flag_if_has != &"":
			GameState.set_flag(flag_if_has)
		_go(scene_if_has)
	else:
		GameState.set_flag(&"phase2_start", "high")
		if flag_if_missing != &"":
			GameState.set_flag(flag_if_missing)
		GameState.set_flag(StringName("missed_" + String(required_item.id)))
		GameState.add_insanity(25,
				"missing " + String(required_item.id))
		if SceneFlow.ending_started:
			return
		_go(scene_if_missing)


func _go(path: String) -> void:
	if path == "" or not ResourceLoader.exists(path):
		push_error("ItemBranch: scene not set or not found -> '%s'" % path)
		return
	get_tree().change_scene_to_file.call_deferred(path)
