extends Control

const QTE_TIME := 6.0
const TIMEOUT_PENALTY := 10

@export var default_choice := "window"          # picked for the player if they freeze
@export_file("*.tscn") var window_scene: String # "Help Noni climb up"
@export_file("*.tscn") var attic_scene: String  # "Treat Dodong's injury"

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
	attic_button.pressed.connect(_choose.bind("attic"))
	window_button.pressed.connect(_choose.bind("window"))


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
	GameState.set_flag(StringName("chose_" + choice))   # chose_window or chose_attic
	QuestLog.complete_objective(SceneFlow.QUEST, 2)

	if SceneFlow.ending_started:
		return
	var path := window_scene if choice == "window" else attic_scene
	if path == "" or not ResourceLoader.exists(path):
		push_error("QTE: scene not set for '%s'" % choice)
		return
	get_tree().change_scene_to_file.call_deferred(path)
