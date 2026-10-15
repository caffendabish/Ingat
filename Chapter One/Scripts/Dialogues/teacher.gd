extends Area2D

@export var dialogue_resource: DialogueResource
@export_file("*.tscn") var minigame_scene: String

@onready var anim: AnimatedSprite2D = $CharacterBody2D/AnimatedSprite2D

var talking := false

func _ready() -> void:
	input_pickable = true
	print("Teacher ready. Dialogue: ", dialogue_resource, " | Scene: ", minigame_scene)
	if anim.sprite_frames and anim.sprite_frames.has_animation("idle"):
		anim.play("idle")
	else:
		push_warning("No 'idle' animation found on AnimatedSprite2D")
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

# Built-in virtual method: no signal connection needed
func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if talking:
		return
	if event is InputEventMouseButton \
			and event.button_index == MOUSE_BUTTON_LEFT \
			and event.pressed:
		print("teacher clicked")
		start_talk()

func start_talk() -> void:
	talking = true
	if dialogue_resource == null:
		push_error("dialogue_resource is not assigned on Teacher")
		return
	DialogueManager.show_dialogue_balloon(dialogue_resource, "start")
	await DialogueManager.dialogue_ended
	if minigame_scene == "":
		push_error("minigame_scene is not assigned on Teacher")
		return
	get_tree().change_scene_to_file(minigame_scene)

func _on_mouse_entered() -> void:
	modulate = Color(1.2, 1.2, 1.2)

func _on_mouse_exited() -> void:
	modulate = Color.WHITE
