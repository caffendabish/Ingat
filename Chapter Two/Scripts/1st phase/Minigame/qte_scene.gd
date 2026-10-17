extends Control

const QTE_TIME := 6.0
const TIMEOUT_PENALTY := 10

# Choice IDs used by Phase 1 (qte_scene) and referenced by Phase 2 (special_qte)
const CHOICE_ATTIC := "attic"   # "Treat Dodong's injury" -> Dodong rect in special_qte
const CHOICE_WINDOW := "window" # "Help Noni climb up"    -> Noni rect in special_qte

@export var default_choice := CHOICE_WINDOW          # picked for the player if they freeze
@export_file("*.tscn") var window_scene: String # "Help Noni climb up"
@export_file("*.tscn") var attic_scene: String  # "Treat Dodong's injury"

# Optional dialogues shown after the QTE choice, before the route scene loads
@export var window_dialogue: DialogueResource
@export var attic_dialogue: DialogueResource

@onready var time_bar: ProgressBar = $TimeBar
@onready var attic_button: Button = $AtticButton
@onready var window_button: Button = $WindowButton

var time_left := QTE_TIME
var done := false


func _ready() -> void:
	GameHUD.hide_hud()
	time_bar.show_percentage = false
	time_bar.max_value = QTE_TIME
	time_bar.value = QTE_TIME
	attic_button.pressed.connect(_choose.bind(CHOICE_ATTIC))
	window_button.pressed.connect(_choose.bind(CHOICE_WINDOW))


func _process(delta: float) -> void:
	if done:
		return
	time_left -= delta
	time_bar.value = time_left
	if time_left <= 0.0:
		GameState.add_insanity(TIMEOUT_PENALTY, "QTE timeout")
		GameState.set_flag(&"qte_timeout")
		_choose(default_choice)


func _choose(choice: String) -> void:
	if done:
		return
	done = true
	GameState.set_flag(StringName("chose_" + choice))   # chose_attic or chose_window
	QuestLog.complete_objective(SceneFlow.QUEST, 2)

	# Show choice-specific dialogue before proceeding to the route scene
	var dialogue := attic_dialogue if choice == CHOICE_ATTIC else window_dialogue
	if dialogue != null and not SceneFlow.ending_started:
		GameHUD.hide_hud()
		DialogueManager.show_dialogue_balloon(dialogue, "start")
		await DialogueManager.dialogue_ended

	if SceneFlow.ending_started:
		return
	var path := window_scene if choice == CHOICE_WINDOW else attic_scene
	if path == "" or not ResourceLoader.exists(path):
		push_error("QTE: scene not set for '%s'" % choice)
		return
	get_tree().change_scene_to_file.call_deferred(path)
