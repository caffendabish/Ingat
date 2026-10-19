extends CanvasLayer

# Scenes where pausing should be disabled
const NO_PAUSE_SCENES := [
	"res://Main Menu/MainMenu.tscn",
]

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 100
	hide()

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_action_pressed("ui_cancel") and not event.is_echo():
			if not can_pause():
				return
			toggle_pause()
			get_viewport().set_input_as_handled()

func can_pause() -> bool:
	var scene := get_tree().current_scene
	if scene == null:
		return false
	return not NO_PAUSE_SCENES.has(scene.scene_file_path)

func toggle_pause() -> void:
	var new_state := not get_tree().paused
	get_tree().paused = new_state
	visible = new_state

func _on_resume_pressed() -> void:
	get_tree().paused = false
	hide()

func _on_main_menu_pressed() -> void:
	# Unpause and hide first, since this node survives the scene change
	get_tree().paused = false
	hide()
	get_tree().change_scene_to_file("res://Main Menu/MainMenu.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
