extends Area2D

@export var dialogue_resource: DialogueResource
@export var dialogue_start: String = "start"
@export var change_scene_after_dialogue := true
@export_file("*.tscn") var next_scene_path: String = "res://Chapter One/Explorations/House/front.tscn"

@onready var overlay: CanvasLayer = $DialogueOverlay

var in_dialogue := false

func _ready() -> void:
	overlay.hide()
	input_event.connect(_on_input_event)

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if in_dialogue:
		return
	if event is InputEventMouseButton \
			and event.button_index == MOUSE_BUTTON_LEFT \
			and event.pressed:
		start_dialogue()

func start_dialogue() -> void:
	in_dialogue = true
	var player := get_tree().get_first_node_in_group("player")
	if player:
		player.process_mode = Node.PROCESS_MODE_DISABLED

	overlay.show()
	DialogueManager.show_dialogue_balloon(dialogue_resource, dialogue_start)
	await DialogueManager.dialogue_ended
	overlay.hide()

	if change_scene_after_dialogue and next_scene_path != "":
		if not ResourceLoader.exists(next_scene_path):
			push_error("Scene not found: " + next_scene_path)
		else:
			get_tree().change_scene_to_file(next_scene_path)
			return

	if player:
		player.process_mode = Node.PROCESS_MODE_INHERIT

	await get_tree().create_timer(0.15).timeout
	in_dialogue = false
