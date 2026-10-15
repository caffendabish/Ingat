extends Node

signal insanity_changed(new_value: int, delta: int)
signal isolated_ending_triggered

const MAX_INSANITY := 100

var insanity: int = 0
var insanity_revealed: bool = false
var flags: Dictionary = {}
var collected_pickups: Array[StringName] = []


func add_insanity(amount: int, reason: String = "") -> void:
	insanity = clampi(insanity + amount, 0, MAX_INSANITY)
	insanity_changed.emit(insanity, amount)
	print("Insanity %+d (%s) -> %d" % [amount, reason, insanity])
	if insanity >= MAX_INSANITY:
		isolated_ending_triggered.emit()


func set_flag(key: StringName, value: Variant = true) -> void:
	flags[key] = value


func has_flag(key: StringName) -> bool:
	return flags.has(key) and bool(flags[key])


func get_flag(key: Variant, default: Variant = null) -> Variant:
	return flags.get(StringName(key), default)


# Wipes EVERYTHING, including the bag. Call it only from the main menu's
# "New Game" button, never from a minigame.
func new_game() -> void:
	insanity = 0
	insanity_revealed = false
	flags.clear()
	collected_pickups.clear()
	Inventory.items.clear()
	QuestLog.clear()
	SceneFlow.ending_started = false
	insanity_changed.emit(0, 0)


# Debug: press F1 while playing
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo \
			and event.keycode == KEY_F1:
		print("Insanity: ", insanity)
		print("Time left: ", MinigameTimer.time_left)
		print("Flags: ", flags)
		for i in Inventory.items:
			print("Has item: ", i.id)
