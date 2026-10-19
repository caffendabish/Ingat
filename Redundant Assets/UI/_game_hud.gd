extends CanvasLayer

@export var meter_frames: Array[Texture2D]   # the 10 meter images, in order

@onready var insanity_bar: TextureRect = $InsanityBar
@onready var vignette: ColorRect = $Vignette
@onready var bag_button: Button = $BagButton
@onready var quest_button: Button = $QuestButton
@onready var quest_toast: Label = $QuestToast
@onready var inventory_ui: Control = $InventoryUI
@onready var quest_log_ui: Control = $QuestLogUI

# Vignette intensity at max insanity (0.0 = none, 1.0 = fully black)
const VIGNETTE_MAX_ALPHA := 0.7
# Slight red tint at high insanity for a more oppressive feel
const VIGNETTE_MAX_RED := 0.15

var hud_enabled := true     # master switch for the whole HUD
var meter_only := false     # true = only the insanity meter is allowed to show
var toast_tween: Tween
var reveal_tween: Tween


func _ready() -> void:
	bag_button.pressed.connect(_toggle_bag)
	quest_button.pressed.connect(_toggle_quests)
	GameState.insanity_changed.connect(_on_insanity_changed)
	QuestLog.quest_added.connect(func(id): _toast("New quest: " + QuestLog.quests[id].title))
	QuestLog.quest_updated.connect(func(_id): _toast("Quest updated"))
	QuestLog.quest_completed.connect(func(id): _toast("Quest complete: " + QuestLog.quests[id].title))
	quest_toast.hide()
	_update_meter(GameState.insanity, false)


func _process(_delta: float) -> void:
	var full_hud := hud_enabled and not meter_only
	bag_button.visible = full_hud
	quest_button.visible = full_hud
	insanity_bar.visible = hud_enabled and (GameState.insanity_revealed or meter_only)

	# Vignette grows darker and slightly redder as insanity rises
	var insanity_ratio := float(GameState.insanity) / float(GameState.MAX_INSANITY)
	var vignette_alpha := lerpf(0.0, VIGNETTE_MAX_ALPHA, insanity_ratio)
	var vignette_red := lerpf(0.0, VIGNETTE_MAX_RED, insanity_ratio)
	vignette.color = Color(vignette_red, 0.0, 0.0, vignette_alpha)

	# never leave a screen open when buttons are hidden
	if not full_hud:
		if inventory_ui.visible:
			inventory_ui.close()
		if quest_log_ui.visible:
			quest_log_ui.close()
		quest_toast.hide()


# Keyboard shortcuts: I = bag, J = quests
func _unhandled_input(event: InputEvent) -> void:
	if not hud_enabled or meter_only:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_I:
			_toggle_bag()
		elif event.keycode == KEY_J:
			_toggle_quests()


func _toggle_bag() -> void:
	if quest_log_ui.visible:
		quest_log_ui.close()
	inventory_ui.toggle()


func _toggle_quests() -> void:
	if inventory_ui.visible:
		inventory_ui.close()
	quest_log_ui.toggle()


func _toast(text: String) -> void:
	if not hud_enabled or meter_only:
		return
	if toast_tween:
		toast_tween.kill()
	quest_toast.text = text
	quest_toast.modulate.a = 0.0
	quest_toast.show()
	toast_tween = create_tween()
	toast_tween.tween_property(quest_toast, "modulate:a", 1.0, 0.3)
	toast_tween.tween_interval(2.0)
	toast_tween.tween_property(quest_toast, "modulate:a", 0.0, 0.6)
	toast_tween.tween_callback(quest_toast.hide)


# ---------- insanity meter ----------

func _frame_index(value: int) -> int:
	var i := roundi(float(value) / GameState.MAX_INSANITY * (meter_frames.size() - 1))
	return clampi(i, 0, meter_frames.size() - 1)


func _on_insanity_changed(new_value: int, _delta: int) -> void:
	_update_meter(new_value, true)


func _update_meter(value: int, animate: bool) -> void:
	if meter_frames.is_empty():
		return
	var new_tex := meter_frames[_frame_index(value)]
	if insanity_bar.texture == new_tex:
		return
	insanity_bar.texture = new_tex
	if animate:
		insanity_bar.modulate = Color(1.6, 1.6, 1.6)
		create_tween().tween_property(insanity_bar, "modulate", Color.WHITE, 0.4)


# The big reveal: ONLY the meter appears. It fades in at the calmest
# frame, then climbs to the player's real value.
func reveal_insanity() -> void:
	show_meter_only()
	GameState.insanity_revealed = true
	if meter_frames.is_empty():
		return
	if reveal_tween:
		reveal_tween.kill()

	var target := _frame_index(GameState.insanity)
	insanity_bar.texture = meter_frames[0]
	insanity_bar.modulate = Color(1, 1, 1, 0)

	reveal_tween = create_tween()
	reveal_tween.tween_property(insanity_bar, "modulate:a", 1.0, 1.0)
	for i in range(1, target + 1):
		reveal_tween.tween_interval(0.4)
		reveal_tween.tween_callback(_set_frame.bind(i))


func _set_frame(i: int) -> void:
	insanity_bar.texture = meter_frames[i]
	insanity_bar.modulate = Color(1.6, 1.6, 1.6)
	create_tween().tween_property(insanity_bar, "modulate", Color.WHITE, 0.3)


# ---------- HUD modes ----------

func hide_hud() -> void:          # nothing shows (cutscenes, QTE)
	hud_enabled = false
	meter_only = false
	visible = false                 # hide the CanvasLayer itself


func show_hud() -> void:          # everything shows (exploring)
	hud_enabled = true
	meter_only = false
	visible = true                  # show the CanvasLayer itself


func show_meter_only() -> void:   # just the insanity meter
	hud_enabled = true
	meter_only = true
	visible = true                  # show the CanvasLayer itself
