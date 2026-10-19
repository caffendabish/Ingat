extends Control

const QTE_TIME := 6.0
const RESULT_DELAY := 0.8   # pause so the meter jump is seen

@export var loss_one_insanity := 25     # lost the father OR the sibling
@export var loss_both_insanity := 35    # lost both (ran out of time)

# Which sibling appears for each Phase 1 choice.
# true  = Attic -> Noni, Window -> Dodong
# false = Attic -> Dodong, Window -> Noni
@export var noni_if_attic := true

# SAVE THE SIBLING (Papa is washed away)
@export_file("*.tscn") var saved_noni_scene: String
@export_file("*.tscn") var saved_dodong_scene: String

# SAVE PAPA (the sibling is washed away)
@export_file("*.tscn") var saved_papa_noni_scene: String
@export_file("*.tscn") var saved_papa_dodong_scene: String

# TIME RAN OUT (both are washed away)
@export_file("*.tscn") var both_lost_scene: String

@onready var noni: TextureRect = $Noni
@onready var dodong: TextureRect = $Dodong
@onready var time_bar: ProgressBar = $TimeBar
@onready var sibling_button: Button = $Sibling
@onready var papa_button: Button = $Papa
@onready var prompt_label: Label = $PromptLabel
@onready var dark_overlay: ColorRect = $DarkOverlay
@onready var blood_overlay: ColorRect = $BloodOverlay
@onready var flicker_overlay: ColorRect = $FlickerOverlay

var time_left := QTE_TIME
var done := false
var sibling_is_noni := true
var flicker_timer := 0.0
var shake_timer := 0.0

# Base positions for shake
var _prompt_base_pos: Vector2
var _sibling_base_pos: Vector2
var _papa_base_pos: Vector2


func _ready() -> void:
	GameHUD.show_meter_only()    # the player watches the meter jump

	# art layers never block the buttons
	noni.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dodong.mouse_filter = Control.MOUSE_FILTER_IGNORE

	_pick_sibling_version()

	time_bar.show_percentage = false
	time_bar.max_value = QTE_TIME
	time_bar.value = QTE_TIME

	dark_overlay.color.a = 0.2
	blood_overlay.color.a = 0.0
	flicker_overlay.color.a = 0.0

	# Store base positions for shake
	_prompt_base_pos = prompt_label.position
	_sibling_base_pos = sibling_button.position
	_papa_base_pos = papa_button.position

	for b in [sibling_button, papa_button]:
		b.focus_mode = Control.FOCUS_NONE
		b.mouse_entered.connect(func(): Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND))
		b.mouse_exited.connect(func(): Input.set_default_cursor_shape(Input.CURSOR_ARROW))

	sibling_button.pressed.connect(_choose.bind("sibling"))
	papa_button.pressed.connect(_choose.bind("father"))


# Shows Noni or Dodong, depending on the Phase 1 choice
func _pick_sibling_version() -> void:
	sibling_is_noni = true   # default when testing this scene alone
	if GameState.has_flag(&"chose_attic"):
		sibling_is_noni = noni_if_attic
	elif GameState.has_flag(&"chose_window"):
		sibling_is_noni = not noni_if_attic

	noni.visible = sibling_is_noni
	dodong.visible = not sibling_is_noni
	GameState.set_flag(&"sibling_name", "Noni" if sibling_is_noni else "Dodong")


func _process(delta: float) -> void:
	if done:
		return
	time_left -= delta
	time_bar.value = time_left

	# Horror intensity grows as time runs out
	var panic: float = 1.0 - clamp(time_left / QTE_TIME, 0.0, 1.0)

	# Dark overlay gets darker as time runs out
	dark_overlay.color.a = lerpf(0.2, 0.85, panic)

	# Blood tint washes over screen as panic increases
	blood_overlay.color.a = lerpf(0.0, 0.35, panic * panic)

	# Flickering light effect
	flicker_timer += delta
	if flicker_timer >= randf_range(0.05, 0.25):
		flicker_timer = 0.0
		flicker_overlay.color.a = randf_range(0.0, 0.4) if randf() > 0.7 else 0.0

	# Screen shake intensifies as panic grows
	shake_timer += delta
	var shake_amount: float = 4.0 + (panic * 12.0)
	var shake_x = sin(shake_timer * 30.0 + panic * 10.0) * shake_amount
	var shake_y = cos(shake_timer * 23.0 + panic * 8.0) * shake_amount
	prompt_label.position = _prompt_base_pos + Vector2(shake_x, shake_y)
	sibling_button.position = _sibling_base_pos + Vector2(shake_x, shake_y)
	papa_button.position = _papa_base_pos + Vector2(shake_y, shake_x)

	# Time bar pulses red when critical
	if panic > 0.7:
		time_bar.modulate.a = 0.5 + 0.5 * sin(shake_timer * 20.0)
		time_bar.modulate = Color(1.0, 0.2, 0.2, time_bar.modulate.a)

	if time_left <= 0.0:
		GameState.set_flag(&"flood_qte_timeout")
		_choose("none")          # running out of time = saving no one


func _choose(who: String) -> void:
	if done:
		return
	done = true
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	sibling_button.disabled = true
	papa_button.disabled = true

	var lost := ""
	var penalty := 0
	var path := ""
	match who:
		"sibling":     # saved the sibling, so Papa is lost
			lost = "father"
			penalty = loss_one_insanity
			path = saved_noni_scene if sibling_is_noni else saved_dodong_scene
		"father":      # saved Papa, so the sibling is lost
			lost = "sibling"
			penalty = loss_one_insanity
			path = saved_papa_noni_scene if sibling_is_noni else saved_papa_dodong_scene
		_:             # saved no one, or ran out of time
			lost = "both"
			penalty = loss_both_insanity
			path = both_lost_scene

	GameState.set_flag(&"flood_saved", who)
	GameState.set_flag(&"flood_lost", lost)
	GameState.set_flag(&"phase3_start", "high")
	GameState.add_insanity(penalty, "flood: lost %s" % lost)

	# a full meter already sent the player to the ending
	if SceneFlow.ending_started:
		return

	await get_tree().create_timer(RESULT_DELAY).timeout
	if path == "" or not ResourceLoader.exists(path):
		push_error("SpecialQTE: outcome scene not set (who=%s, noni=%s)" % [who, sibling_is_noni])
		return
	get_tree().change_scene_to_file.call_deferred(path)
