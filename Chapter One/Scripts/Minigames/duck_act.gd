extends Node2D

const INTRO_DIALOGUE := preload("res://Chapter One/Dialogues/2.1 - CLASSROOM_Duckling Activity.dialogue")
const JUMPSCARE_TEXTURE := preload("res://Chapter Two/Assets/LVL 2 QTE EVENT/JUMPSCARE1.png")

static var intro_played := false

@onready var ducky = $CharacterBody2D
@onready var flash_overlay = $FlashOverlay
@onready var jumpscare_image = $JumpscareImage


func _ready() -> void:
	if intro_played:
		ducky.can_drag = true
		return
	intro_played = true

	DialogueManager.show_dialogue_balloon(INTRO_DIALOGUE, "start")
	await DialogueManager.dialogue_ended
	ducky.can_drag = true
	GameHUD.hide()

func _on_area_2d_body_entered(body: Node2D) -> void:
	# Jumpscare before transitioning
	flash_overlay.color.a = 0.0
	jumpscare_image.texture = JUMPSCARE_TEXTURE
	jumpscare_image.visible = true
	flash_overlay.show()

	var flash_tween := create_tween()
	flash_tween.tween_property(flash_overlay, "color:a", 0.9, 0.1)
	flash_tween.tween_property(flash_overlay, "color:a", 0.0, 0.2)

	await create_tween().tween_interval(0.5).finished

	jumpscare_image.visible = false
	flash_overlay.hide()

	get_tree().change_scene_to_file("res://Chapter One/Explorations/School/classroomaft.tscn")
