extends Node

signal time_up

const DEFAULT_TIME := 60.0

var time_left: float = 0.0
var running := false
var paused := false
var finished := false   # becomes true once the countdown runs out


func start(seconds: float = DEFAULT_TIME) -> void:
	time_left = seconds
	running = true
	paused = false
	finished = false


# Safe to call from EVERY room. It only starts the clock once, and never
# restarts it after it has finished.
func ensure_started(seconds: float = DEFAULT_TIME) -> void:
	if running or finished:
		return
	start(seconds)


# Clears everything, for a new game or a new minigame
func reset() -> void:
	running = false
	paused = false
	finished = false
	time_left = 0.0


func stop() -> void:
	running = false
	paused = false


func _process(delta: float) -> void:
	if not running or paused:
		return
	time_left -= delta
	if time_left <= 0.0:
		time_left = 0.0
		running = false
		finished = true
		time_up.emit()
