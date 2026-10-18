extends Node2D

const INTRO_DIALOGUE := preload("res://Chapter One/Dialogues/1-SCHOOL_Ritchie&OllieConvo.dialogue")

static var intro_played := false

@onready var dialogue_overlay: CanvasLayer = %FirstTalk
@onready var instructions: AnimatedSprite2D = $Instructions

var waiting_for_instructions := false


func _ready() -> void:
	if intro_played:
		instructions.visible = false
		return
	intro_played = true

	# Block field interaction during the intro sequence
	var field := get_node_or_null("Field") as Area2D
	if field:
		field.monitoring = false

	dialogue_overlay.show()
	DialogueManager.show_dialogue_balloon(INTRO_DIALOGUE, "start")
	await DialogueManager.dialogue_ended
	dialogue_overlay.hide()

	# Show instructions animation until player clicks it
	instructions.visible = true
	instructions.play()
	waiting_for_instructions = true

	# Wait until the player clicks the instructions
	while waiting_for_instructions:
		await get_tree().create_timer(0.1).timeout

	# Re-enable field interaction once the intro is done
	if field:
		field.monitoring = true
	GameHUD.show_hud()

func _input(event: InputEvent) -> void:
	if not waiting_for_instructions:
		return
	if event is InputEventMouseButton and event.pressed:
		# Click anywhere to dismiss the instructions animation
		instructions.visible = false
		waiting_for_instructions = false


func _on_field_body_entered(body: Node2D) -> void:
	get_tree().change_scene_to_file("res://Chapter One/Explorations/School/field.tscn")
